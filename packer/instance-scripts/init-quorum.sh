#!/bin/bash
set -u -o pipefail

# Set vault address since this will be run by user-data
export VAULT_ADDR=https://vault.service.consul:8200

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
    local IP=$3
    local ROLE=$4
    local NUM_MAKERS=$5
    local NUM_BOOTNODES=$6
    local CONSTELLATION_CONFIG=$7

    local NETID=$(cat /opt/quorum/info/network-id.txt)

    local VERBOSITY=3
    local MIN_BLOCK_TIME=2
    local MAX_BLOCK_TIME=5
    local PW_FILE="/tmp/geth-pw"
    local GLOBAL_ARGS="--networkid $NETID --rpc --rpcaddr $IP --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum --rpcport 22000 --rpccorsdomain \"*\" --port 21000 --verbosity $VERBOSITY --jitvm=false --privateconfigpath $CONSTELLATION_CONFIG"

    if [ "$ROLE" == "maker" ]
    then
        ARGS="$GLOBAL_ARGS --blockmakeraccount \"$ADDRESS\" --blockmakerpassword \"$PASSWORD\" --minblocktime $MIN_BLOCK_TIME --maxblocktime $MAX_BLOCK_TIME"
        if [ $NUM_MAKERS -eq 1 ]
        then
            ARGS="$ARGS --singleblockmaker"
        fi
    elif [ "$ROLE" == "validator" ]
    then
        ARGS="$GLOBAL_ARGS --voteaccount \"$ADDRESS\" --votepassword \"$PASSWORD\""
    else # observer node
        echo "$PASSWORD" > $PW_FILE
        ARGS="$GLOBAL_ARGS --unlock \"$ADDRESS\" --password \"$PW_FILE\""
    fi

    local BOOTNODES=""
    for index in $(seq 0 $(expr $NUM_BOOTNODES - 1))
    do
        BOOTNODES="$BOOTNODES,$(vault read -field=enode quorum/bootnodes/addresses/$index)"
    done
    BOOTNODES=${BOOTNODES:1}

    ARGS="$ARGS --bootnodes $BOOTNODES"

    local COMMAND="geth $ARGS"

    echo "[program:quorum]
command=$COMMAND
stdout_logfile=/opt/quorum/log/quorum-stdout.log
stderr_logfile=/opt/quorum/log/quorum-error.log
numprocs=1
autostart=true
autorestart=true
stopsignal=INT
user=ubuntu" | sudo tee /etc/supervisor/conf.d/quorum-supervisor.conf
}

function complete_constellation_config {
    local NUM_BOOTNODES=$1
    local PRIVATE_IP=$2
    local CONSTELLATION_CONFIG_PATH=$3

    local OTHER_NODES=""

    # Configure constellation with bootnode IPs
    for index in $(seq 0 $(expr $NUM_BOOTNODES - 1))
    do
        BOOTNODE=$(wait_for_successful_command "vault read -field=private_ip quorum/bootnodes/addresses/$index")
        OTHER_NODES="$OTHER_NODES,\"http://$BOOTNODE:9000/\""
    done
    OTHER_NODES=${OTHER_NODES:1}
    OTHER_NODES_LINE="othernodes = [$OTHER_NODES]"

    echo "$OTHER_NODES_LINE" >> $CONSTELLATION_CONFIG_PATH

    # Configure constellation with URL
    echo "url = \"http://$PRIVATE_IP:9000/\"" >> $CONSTELLATION_CONFIG_PATH
}

function generate_genesis_file {
    # Assemble lists of addresses
    local VOTE_THRESHOLD=$(cat /opt/quorum/info/vote-threshold.txt)
    local NUM_MAKERS=$(cat /opt/quorum/info/num-makers.txt)
    local NUM_VALIDATORS=$(cat /opt/quorum/info/num-validators.txt)
    local NUM_OBSERVERS=$(cat /opt/quorum/info/num-observers.txt)
    local MAKERS=()
    local VALIDATORS=()
    local OBSERVERS=()

    for index in $(seq 0 $(expr $NUM_MAKERS - 1))
    do
        MAKERS[$index]=$(wait_for_successful_command "vault read -field=address quorum/makers/$index")
    done

    for index in $(seq 0 $(expr $NUM_VALIDATORS - 1))
    do
        VALIDATORS[$index]=$(wait_for_successful_command "vault read -field=address quorum/validators/$index")
    done

    for index in $(seq 0 $(expr $NUM_OBSERVERS - 1))
    do
        OBSERVERS[$index]=$(wait_for_successful_command "vault read -field=address quorum/observers/$index")
    done

    # Generate the quorum config and genesis now that we have all the info we need
    python /opt/quorum/bin/generate-quorum-config.py --makers ${MAKERS[@]} --validators ${VALIDATORS[@]} --observers ${OBSERVERS[@]} --vote-threshold $VOTE_THRESHOLD
    (cd /opt/quorum/private && quorum-genesis)

    # Make sure genesis file exists before continuing
    until [ -e /opt/quorum/private/quorum-genesis.json ]
    do
        sleep 1
    done
}

function broadcast_role_info {
    local ROLE=$1

    local ROLE_INDEX=$(cat /opt/quorum/info/role-index.txt)

    if [ "$ROLE" == "maker" ]
    then
        wait_for_successful_command "vault write quorum/makers/$ROLE_INDEX address=$ADDRESS"
    elif [ "$ROLE" == "validator" ]
    then
        wait_for_successful_command "vault write quorum/validators/$ROLE_INDEX address=$ADDRESS"
    else # ROLE == observer
        wait_for_successful_command "vault write quorum/observers/$ROLE_INDEX address=$ADDRESS"
    fi
}

function wait_for_all_nodes {
    local NETWORK_SIZE=$(cat /opt/quorum/info/network-size.txt)

    for index in $(seq 0 $(expr $NETWORK_SIZE - 1))
    do
        wait_for_successful_command "vault read -field=address quorum/addresses/$index"
    done
}

function wait_for_all_bootnodes {
    local NUM_BOOTNODES=$1

    for index in $(seq 0 $(expr $NUM_BOOTNODES - 1))
    do
        wait_for_successful_command "vault read -field=enode quorum/bootnodes/addresses/$index"
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

# Get the overall index for this instance
CLUSTER_INDEX=$(cat /opt/quorum/info/overall-index.txt)

# Load Address, Password, and Key if we already generated them or generate new ones if none exist
ADDRESS=$(vault read -field=address quorum/addresses/$CLUSTER_INDEX)
if [ $? -eq 0 ]
then
    # Address is already in vault and this is a replacement instance.  Load info from vault
    GETH_PW=$(wait_for_successful_command "vault read -field=geth_pw quorum/passwords/$CLUSTER_INDEX")
    CONSTELLATION_PW=$(wait_for_successful_command "vault read -field=constellation_pw quorum/passwords/$CLUSTER_INDEX")
    # Generate constellation key files
    wait_for_successful_command "vault read -field=constellation_pub_key quorum/addresses/$CLUSTER_INDEX" > /opt/quorum/constellation/private/constellation.pub
    wait_for_successful_command "vault read -field=constellation_priv_key quorum/keys/$CLUSTER_INDEX" > /opt/quorum/constellation/private/constellation.key
    # Generate geth key file
    GETH_KEY_FILE_NAME=$(wait_for_successful_command "vault read -field=geth_key_file quorum/keys/$CLUSTER_INDEX")
    GETH_KEY_FILE_DIR="/home/ubuntu/.ethereum/keystore"
    mkdir -p $GETH_KEY_FILE_DIR
    GETH_KEY_FILE_PATH="$GETH_KEY_FILE_DIR/$GETH_KEY_FILE_NAME"
    wait_for_successful_command "vault read -field=geth_key quorum/keys/$CLUSTER_INDEX" > $GETH_KEY_FILE_PATH
elif [ -e /home/ubuntu/.ethereum/keystore/* ]
then
    # Address was created but not stored in vault. This is a process reboot after a previous failure.
    # Load address from file and password from vault
    GETH_PW=$(wait_for_successful_command "vault read -field=geth_pw quorum/passwords/$CLUSTER_INDEX")
    CONSTELLATION_PW=$(wait_for_successful_command "vault read -field=constellation_pw quorum/passwords/$CLUSTER_INDEX")
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
    wait_for_successful_command "vault write quorum/passwords/$CLUSTER_INDEX geth_pw=\"$GETH_PW\" constellation_pw=\"$CONSTELLATION_PW\""
    # Generate the new key pair
    ADDRESS=0x$(echo -ne "$GETH_PW\n$GETH_PW\n" | geth account new | grep Address | awk '{ gsub("{|}", "") ; print $2 }')
    # Generate constellation keys
    echo "$CONSTELLATION_PW" | constellation-node --generatekeys=/opt/quorum/constellation/private/constellation
fi
CONSTELLATION_PUB_KEY=$(cat /opt/quorum/constellation/private/constellation.pub)
CONSTELLATION_PRIV_KEY=$(cat /opt/quorum/constellation/private/constellation.key)
PRIVATE_IP=$(wait_for_successful_command 'curl http://169.254.169.254/latest/meta-data/local-ipv4')
PRIV_KEY=$(cat /home/ubuntu/.ethereum/keystore/*$(echo $ADDRESS | cut -d 'x' -f2))
PRIV_KEY_FILENAME=$(ls /home/ubuntu/.ethereum/keystore/)

# Determine role and advertise as role
ROLE=$(cat /opt/quorum/info/role.txt)
broadcast_role_info $ROLE

# Write key and address into the vault
wait_for_successful_command "vault write quorum/keys/$CLUSTER_INDEX geth_key=$PRIV_KEY geth_key_file=$PRIV_KEY_FILENAME constellation_priv_key=$CONSTELLATION_PRIV_KEY"
wait_for_successful_command "vault write quorum/addresses/$CLUSTER_INDEX address=$ADDRESS constellation_pub_key=$CONSTELLATION_PUB_KEY private_ip=$PRIVATE_IP"

# Wait for all nodes to write their address to vault
NUM_BOOTNODES=$(cat /opt/quorum/info/num-bootnodes.txt)
wait_for_all_nodes
wait_for_all_bootnodes $NUM_BOOTNODES

complete_constellation_config $NUM_BOOTNODES $PRIVATE_IP /opt/quorum/constellation/config.conf

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
NUM_MAKERS=$(cat /opt/quorum/info/num-makers.txt)
generate_quorum_supervisor_config $ADDRESS $GETH_PW $PRIVATE_IP $ROLE $NUM_MAKERS $NUM_BOOTNODES /opt/quorum/constellation/config.conf

# Remove the config that runs this and run quorum
sudo rm /etc/supervisor/conf.d/init-quorum-supervisor.conf
sudo supervisorctl reread
sudo supervisorctl update
