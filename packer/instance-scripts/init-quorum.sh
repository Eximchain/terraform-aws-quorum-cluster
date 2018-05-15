#!/bin/bash
set -u -o pipefail

function wait_for_successful_command {
    local COMMAND=$1

    $COMMAND
    until [ $? -eq 0 ]
    do
        sleep 5
        $COMMAND
    done
}

function generate_quorum_supervisor_config {
    local ADDRESS=$1
    local PASSWORD=$2
    local HOSTNAME=$3
    local ROLE=$4
    local CONSTELLATION_CONFIG=$5

    local NETID=$(cat /opt/quorum/info/network-id.txt)
    local REGIONS=$(cat /opt/quorum/info/regions.txt)
    local MIN_BLOCK_TIME=$(cat /opt/quorum/info/min-block-time.txt)
    local MAX_BLOCK_TIME=$(cat /opt/quorum/info/max-block-time.txt)

    local VERBOSITY=2
    local PW_FILE="/tmp/geth-pw"
    local GLOBAL_ARGS="--networkid $NETID --rpc --rpcaddr $HOSTNAME --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum --rpcport 22000 --rpccorsdomain \"*\" --port 21000 --verbosity $VERBOSITY --jitvm=false --privateconfigpath $CONSTELLATION_CONFIG"

    # Assemble list of bootnodes
    local BOOTNODES=""
    for region in ${REGIONS[@]}
    do
        local NUM_BOOTNODES=$(cat /opt/quorum/info/bootnode-counts/${region}.txt)
        for index in $(seq 0 $(expr $NUM_BOOTNODES - 1))
        do
            BOOTNODES="$BOOTNODES,$(vault read -field=enode quorum/bootnodes/addresses/${region}/$index)"
        done
    done
    BOOTNODES=${BOOTNODES:1}

    if [ "$ROLE" == "maker" ]
    then
        ARGS="$GLOBAL_ARGS --blockmakeraccount \"$ADDRESS\" --blockmakerpassword \"$PASSWORD\" --minblocktime $MIN_BLOCK_TIME --maxblocktime $MAX_BLOCK_TIME"
    elif [ "$ROLE" == "validator" ]
    then
        ARGS="$GLOBAL_ARGS --voteaccount \"$ADDRESS\" --votepassword \"$PASSWORD\""
    else # observer node
        echo "$PASSWORD" > $PW_FILE
        ARGS="$GLOBAL_ARGS --unlock \"$ADDRESS\" --password \"$PW_FILE\""
    fi

    ARGS="$ARGS --bootnodes $BOOTNODES"

    local COMMAND="geth $ARGS"

    echo "[program:quorum]
command=$COMMAND
stdout_logfile=/opt/quorum/log/quorum-stdout.log
stderr_logfile=/opt/quorum/log/quorum-error.log
numprocs=1
autostart=true
autorestart=false
stopsignal=INT
user=ubuntu" | sudo tee /etc/supervisor/conf.d/quorum-supervisor.conf
}

function generate_quorum_crash_listener {
    local METRIC_NAME="QuorumNodeCrashes"
    echo "[eventlistener:crashquorum]
command=/opt/quorum/bin/crashcloudwatch.py -p quorum -m $METRIC_NAME
stdout_logfile=/opt/quorum/log/crashquorum-stdout.log
stderr_logfile=/opt/quorum/log/crashquorum-error.log
numprocs=1
autostart=true
autorestart=unexpected
stopsignal=QUIT
user=ubuntu
events=PROCESS_STATE" | sudo tee /etc/supervisor/conf.d/crashquorum-supervisor.conf
}

function generate_constellation_crash_listener {
    local METRIC_NAME="ConstellationNodeCrashes"
    echo "[eventlistener:crashconstellation]
command=/opt/quorum/bin/crashcloudwatch.py -p constellation -m $METRIC_NAME
stdout_logfile=/opt/quorum/log/crashconstellation-stdout.log
stderr_logfile=/opt/quorum/log/crashconstellation-error.log
numprocs=1
autostart=true
autorestart=unexpected
stopsignal=QUIT
user=ubuntu
events=PROCESS_STATE" | sudo tee /etc/supervisor/conf.d/crashconstellation-supervisor.conf
}

function generate_cloudwatch_metrics_supervisor_config {
    local RPC_DNS=$1
    local RPC_PORT=$2

    echo "[program:cloudwatchmetrics]
command=/opt/quorum/bin/cloudwatch-metrics.sh $RPC_DNS $RPC_PORT
stdout_logfile=/opt/quorum/log/cloudwatch-metrics-stdout.log
stderr_logfile=/opt/quorum/log/cloudwatch-metrics-error.log
numprocs=1
autostart=true
autorestart=true
stopsignal=INT
user=ubuntu" | sudo tee /etc/supervisor/conf.d/cloudwatch-metrics-supervisor.conf
}

function complete_constellation_config {
    local HOSTNAME=$1
    local CONSTELLATION_CONFIG_PATH=$2

    local REGIONS=$(cat /opt/quorum/info/regions.txt)
    local OTHER_NODES=""

    # Configure constellation with bootnode IPs
    for region in ${REGIONS[@]}
    do
        local NUM_BOOTNODES=$(cat /opt/quorum/info/bootnode-counts/${region}.txt)
        for index in $(seq 0 $(expr $NUM_BOOTNODES - 1))
        do
            BOOTNODE=$(wait_for_successful_command "vault read -field=hostname quorum/bootnodes/addresses/${region}/$index")
            OTHER_NODES="$OTHER_NODES,\"http://$BOOTNODE:9000/\""
        done
    done
    OTHER_NODES=${OTHER_NODES:1}
    OTHER_NODES_LINE="othernodes = [$OTHER_NODES]"

    echo "$OTHER_NODES_LINE" >> $CONSTELLATION_CONFIG_PATH

    # Configure constellation with URL
    echo "url = \"http://$HOSTNAME:9000/\"" >> $CONSTELLATION_CONFIG_PATH
}

function generate_genesis_file {
    # Assemble lists of addresses
    local REGIONS=$(cat /opt/quorum/info/regions.txt)
    local VOTE_THRESHOLD=$(cat /opt/quorum/info/vote-threshold.txt)
    local GAS_LIMIT=$(cat /opt/quorum/info/gas-limit.txt)
    local MAKERS=()
    local VALIDATORS=()
    local OBSERVERS=()

    for region in ${REGIONS[@]}
    do
        local NUM_MAKERS=$(cat /opt/quorum/info/maker-counts/${region}.txt)
        for index in $(seq 0 $(expr $NUM_MAKERS - 1))
        do
            MAKERS+=($(wait_for_successful_command "vault read -field=address quorum/makers/${region}/$index"))
        done
    done

    for region in ${REGIONS[@]}
    do
        local NUM_VALIDATORS=$(cat /opt/quorum/info/validator-counts/${region}.txt)
        for index in $(seq 0 $(expr $NUM_VALIDATORS - 1))
        do
            VALIDATORS+=($(wait_for_successful_command "vault read -field=address quorum/validators/${region}/$index"))
        done
    done

    for region in ${REGIONS[@]}
    do
        local NUM_OBSERVERS=$(cat /opt/quorum/info/observer-counts/${region}.txt)
        for index in $(seq 0 $(expr $NUM_OBSERVERS - 1))
        do
            OBSERVERS+=($(wait_for_successful_command "vault read -field=address quorum/observers/${region}/$index"))
        done
    done

    # Generate the quorum config and genesis now that we have all the info we need
    python /opt/quorum/bin/generate-quorum-config.py --makers ${MAKERS[@]} --validators ${VALIDATORS[@]} --observers ${OBSERVERS[@]} --vote-threshold $VOTE_THRESHOLD --gas-limit $GAS_LIMIT
    (cd /opt/quorum/private && quorum-genesis)

    # Make sure genesis file exists before continuing
    until [ -e /opt/quorum/private/quorum-genesis.json ]
    do
        sleep 1
    done
}

function broadcast_role_info {
    local ROLE=$1
    local AWS_REGION=$2

    local ROLE_INDEX=$(cat /opt/quorum/info/role-index.txt)

    if [ "$ROLE" == "maker" ]
    then
        wait_for_successful_command "vault write quorum/makers/$AWS_REGION/$ROLE_INDEX address=$ADDRESS"
    elif [ "$ROLE" == "validator" ]
    then
        wait_for_successful_command "vault write quorum/validators/$AWS_REGION/$ROLE_INDEX address=$ADDRESS"
    else # ROLE == observer
        wait_for_successful_command "vault write quorum/observers/$AWS_REGION/$ROLE_INDEX address=$ADDRESS"
    fi
}

function wait_for_all_nodes {
    local REGIONS=$(cat /opt/quorum/info/regions.txt)

    for region in ${REGIONS[@]}
    do
        local NUM_NODES=$(cat /opt/quorum/info/node-counts/${region}.txt)
        for index in $(seq 0 $(expr $NUM_NODES - 1))
        do
            wait_for_successful_command "vault read -field=address quorum/addresses/${region}/$index"
        done
    done
}

function wait_for_all_bootnodes {
    local REGIONS=$(cat /opt/quorum/info/regions.txt)

    for region in ${REGIONS[@]}
    do
        local NUM_BOOTNODES=$(cat /opt/quorum/info/bootnode-counts/${region}.txt)
        for index in $(seq 0 $(expr $NUM_BOOTNODES - 1))
        do
            wait_for_successful_command "vault read -field=enode quorum/bootnodes/addresses/$region/$index"
        done
    done
}

function wait_for_terraform_provisioners {
    # Ensure terraform has run all provisioners
    while [ ! -e /opt/quorum/info/network-id.txt ]
    do
        sleep 5
    done
}

# Wait for operator to initialize and unseal vault
wait_for_successful_command 'vault init -check'
wait_for_successful_command 'vault status'

# Wait for vault to be fully configured by the root user
wait_for_successful_command 'vault auth -method=aws'

wait_for_terraform_provisioners

# Get the region and overall index for this instance
CLUSTER_INDEX=$(cat /opt/quorum/info/overall-index.txt)
AWS_REGION=$(cat /opt/quorum/info/aws-region.txt)

# Load Address, Password, and Key if we already generated them or generate new ones if none exist
ADDRESS=$(vault read -field=address quorum/addresses/$AWS_REGION/$CLUSTER_INDEX)
if [ $? -eq 0 ]
then
    # Address is already in vault and this is a replacement instance.  Load info from vault
    GETH_PW=$(wait_for_successful_command "vault read -field=geth_pw quorum/passwords/$AWS_REGION/$CLUSTER_INDEX")
    CONSTELLATION_PW=$(wait_for_successful_command "vault read -field=constellation_pw quorum/passwords/$AWS_REGION/$CLUSTER_INDEX")
    # Generate constellation key files
    wait_for_successful_command "vault read -field=constellation_pub_key quorum/addresses/$AWS_REGION/$CLUSTER_INDEX" > /opt/quorum/constellation/private/constellation.pub
    wait_for_successful_command "vault read -field=constellation_priv_key quorum/keys/$AWS_REGION/$CLUSTER_INDEX" > /opt/quorum/constellation/private/constellation.key
    # Generate geth key file
    GETH_KEY_FILE_NAME=$(wait_for_successful_command "vault read -field=geth_key_file quorum/keys/$AWS_REGION/$CLUSTER_INDEX")
    GETH_KEY_FILE_DIR="/home/ubuntu/.ethereum/keystore"
    mkdir -p $GETH_KEY_FILE_DIR
    GETH_KEY_FILE_PATH="$GETH_KEY_FILE_DIR/$GETH_KEY_FILE_NAME"
    wait_for_successful_command "vault read -field=geth_key quorum/keys/$AWS_REGION/$CLUSTER_INDEX" > $GETH_KEY_FILE_PATH
elif [ -e /home/ubuntu/.ethereum/keystore/* ]
then
    # Address was created but not stored in vault. This is a process reboot after a previous failure.
    # Load address from file and password from vault
    GETH_PW=$(wait_for_successful_command "vault read -field=geth_pw quorum/passwords/$AWS_REGION/$CLUSTER_INDEX")
    CONSTELLATION_PW=$(wait_for_successful_command "vault read -field=constellation_pw quorum/passwords/$AWS_REGION/$CLUSTER_INDEX")
    ADDRESS=0x$(cat /home/ubuntu/.ethereum/keystore/* | jq -r .address)
    # Generate constellation keys if they weren't generated last run
    if [ ! -e /opt/quorum/constellation/private/constellation.* ]
    then
        echo "$CONSTELLATION_PW" | constellation-node --generatekeys=/opt/quorum/constellation/private/constellation
    fi
else
    # This is the first run, generate a new key and password
    GETH_PW=$(uuidgen -r)
    # TODO: Get non-empty passwords to work
    CONSTELLATION_PW=""
    # Store the password first so we don't lose it
    wait_for_successful_command "vault write quorum/passwords/$AWS_REGION/$CLUSTER_INDEX geth_pw=\"$GETH_PW\" constellation_pw=\"$CONSTELLATION_PW\""
    # Generate the new key pair
    ADDRESS=0x$(echo -ne "$GETH_PW\n$GETH_PW\n" | geth account new | grep Address | awk '{ gsub("{|}", "") ; print $2 }')
    # Generate constellation keys
    echo "$CONSTELLATION_PW" | constellation-node --generatekeys=/opt/quorum/constellation/private/constellation
fi
CONSTELLATION_PUB_KEY=$(cat /opt/quorum/constellation/private/constellation.pub)
CONSTELLATION_PRIV_KEY=$(cat /opt/quorum/constellation/private/constellation.key)
HOSTNAME=$(wait_for_successful_command 'curl http://169.254.169.254/latest/meta-data/public-hostname')
PRIV_KEY=$(cat /home/ubuntu/.ethereum/keystore/*$(echo $ADDRESS | cut -d 'x' -f2))
PRIV_KEY_FILENAME=$(ls /home/ubuntu/.ethereum/keystore/)

# Determine role and advertise as role
ROLE=$(cat /opt/quorum/info/role.txt)
broadcast_role_info $ROLE $AWS_REGION

# Write key and address into the vault
wait_for_successful_command "vault write quorum/keys/$AWS_REGION/$CLUSTER_INDEX geth_key=$PRIV_KEY geth_key_file=$PRIV_KEY_FILENAME constellation_priv_key=$CONSTELLATION_PRIV_KEY"
wait_for_successful_command "vault write quorum/addresses/$AWS_REGION/$CLUSTER_INDEX address=$ADDRESS constellation_pub_key=$CONSTELLATION_PUB_KEY hostname=$HOSTNAME"

# Wait for all nodes to write their address to vault
wait_for_all_nodes
wait_for_all_bootnodes

complete_constellation_config $HOSTNAME /opt/quorum/constellation/config.conf

# Generate the genesis file
generate_genesis_file

# Initialize geth to run on the quorum network
geth init /opt/quorum/private/quorum-genesis.json

# Sleep to let constellation bootnodes start first
sleep 30

# Run Constellation
sudo mv /opt/quorum/private/constellation-supervisor.conf /etc/supervisor/conf.d/
sudo supervisorctl reread
sudo supervisorctl update

# Sleep to let constellation-node start
sleep 5

# Generate supervisor config to run quorum
generate_quorum_supervisor_config $ADDRESS $GETH_PW $HOSTNAME $ROLE /opt/quorum/constellation/config.conf

# Start processes that generate CloudWatch metrics
if [ $(cat /opt/quorum/info/generate-metrics.txt) == "1" ]
then
    generate_quorum_crash_listener
    generate_constellation_crash_listener
    generate_cloudwatch_metrics_supervisor_config $HOSTNAME 22000
fi

# Remove the config that runs this and run quorum
sudo rm /etc/supervisor/conf.d/init-quorum-supervisor.conf
sudo supervisorctl reread
sudo supervisorctl update
