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
    local CONSTELLATION_CONFIG=$6

    local VERBOSITY=3
    local MIN_BLOCK_TIME=2
    local MAX_BLOCK_TIME=5
    local NETID=64813
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
    else
        ARGS="$GLOBAL_ARGS"
    fi

    local COMMAND="geth $ARGS"

    echo "[program:quorum]
command=$COMMAND
stdout_logfile=/opt/quorum/log/quorum-stdout.log
stderr_logfile=/opt/quorum/log/quorum-error.log
numprocs=1
autostart=true
autorestart=unexpected
stopsignal=INT
environment=PRIVATE_CONFIG=\"$CONSTELLATION_CONFIG\"" | sudo tee /etc/supervisor/conf.d/quorum-supervisor.conf
}

# Wait for operator to initialize and unseal vault
wait_for_successful_command 'vault init -check'
wait_for_successful_command 'vault status'

# Wait for vault to be fully configured by the root user
wait_for_successful_command 'vault auth -method=aws'

# Get the overall index for this instance
CLUSTER_INDEX=$(cat /opt/quorum/info/overall-index.txt)

# Load Address, Password, and Key if we already generated them or generate new ones if none exist
ADDRESS=$(vault read -field=address quorum/addresses/$CLUSTER_INDEX)
if [ $? -eq 0 ]
then
    # Address is already in vault and this is a replacement instance.  Load info from vault
    GETH_PW=$(vault read -field=geth_pw quorum/passwords/$CLUSTER_INDEX)
    CONSTELLATION_PW=$(vault read -field=constellation_pw quorum/passwords/$CLUSTER_INDEX)
    # Generate constellation key files
    vault read -field=constellation_pub_key quorum/addresses/$CLUSTER_INDEX > /opt/quorum/constellation/private/constellation.pub
    vault read -field=constellation_priv_key quorum/keys/$CLUSTER_INDEX > /opt/quorum/constellation/private/constellation.key
elif [ -e /home/ubuntu/.ethereum/keystore/* ]
then
    # Address was created but not stored in vault. This is a process reboot after a previous failure.
    # Load address from file and password from vault
    GETH_PW=$(vault read -field=geth_pw quorum/passwords/$CLUSTER_INDEX)
    CONSTELLATION_PW=$(vault read -field=constellation_pw quorum/passwords/$CLUSTER_INDEX)
    ADDRESS=0x$(cat /home/ubuntu/.ethereum/keystore/* | jq -r .address)
    # Generate constellation keys if they weren't generated last run
    if [ ! -e /opt/quorum/constellation/private/constellation.* ]
    then
        echo "$CONSTELLATION_PW" | constellation-node --generatekeys=/opt/quorum/constellation/private/constellation
        echo "$CONSTELLATION_PW" | constellation-node --generatekeys=/opt/quorum/constellation/private/constellation_a
    fi
else
    # This is the first run, generate a new key and password
    GETH_PW=$(uuidgen -r)
    # TODO: Get non-empty passwords to work
    CONSTELLATION_PW=""
    # Store the password first so we don't lose it
    vault write quorum/passwords/$CLUSTER_INDEX geth_pw="$GETH_PW" constellation_pw="$CONSTELLATION_PW"
    # Generate the new key pair
    ADDRESS=0x$(echo -ne "$GETH_PW\n$GETH_PW\n" | geth account new | grep Address | awk '{ gsub("{|}", "") ; print $2 }')
    # Generate constellation keys
    echo "$CONSTELLATION_PW" | constellation-node --generatekeys=/opt/quorum/constellation/private/constellation
    echo "$CONSTELLATION_PW" | constellation-node --generatekeys=/opt/quorum/constellation/private/constellation_a
fi
CONSTELLATION_PUB_KEY=$(cat /opt/quorum/constellation/private/constellation.pub)
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
CONSTELLATION_PRIV_KEY=$(cat /opt/quorum/constellation/private/constellation.key)
PRIV_KEY=$(cat /home/ubuntu/.ethereum/keystore/*$(echo $ADDRESS | cut -d 'x' -f2))

# Determine role and advertise as maker or validator if appropriate
ROLE=$(cat /opt/quorum/info/role.txt)
ROLE_INDEX=$(cat /opt/quorum/info/role-index.txt)

if [ "$ROLE" == "maker" ]
then
    vault write quorum/makers/$ROLE_INDEX address=$ADDRESS
fi

if [ "$ROLE" == "validator" ]
then
    vault write quorum/validators/$ROLE_INDEX address=$ADDRESS
fi

# Write key and address into the vault
wait_for_successful_command "vault write quorum/keys/$CLUSTER_INDEX geth_key=$PRIV_KEY constellation_priv_key=$CONSTELLATION_PRIV_KEY"
wait_for_successful_command "vault write quorum/addresses/$CLUSTER_INDEX address=$ADDRESS constellation_pub_key=$CONSTELLATION_PUB_KEY private_ip=$PRIVATE_IP"

# Wait for all nodes to write their address to vault
NETWORK_SIZE=$(cat /opt/quorum/info/network-size.txt)
for index in $(seq 0 $(expr $NETWORK_SIZE - 1))
do
    wait_for_successful_command "vault read -field=address quorum/addresses/$index"
done

# Configure constellation with other node IPs
# TODO: New-style configs
if [ 0 -eq $CLUSTER_INDEX ]
then
#    CONSTELLATION_OTHER_NODES="othernodes = []"
    CONSTELLATION_OTHER_NODES="otherNodeUrls = []"
else
    NODE_0_IP=$(vault read -field=private_ip quorum/addresses/0)
#    CONSTELLATION_OTHER_NODES="othernodes = [\"http://$NODE_0_IP:9000/\"]"
    CONSTELLATION_OTHER_NODES="otherNodeUrls = [\"http://$NODE_0_IP:9000/\"]"
fi
echo "$CONSTELLATION_OTHER_NODES" >> /opt/quorum/constellation/config.conf

# Configure constellation with URL
echo "url = \"http://$PRIVATE_IP:9000/\"" >> /opt/quorum/constellation/config.conf

# Assemble the list of makers and validators
NUM_MAKERS=$(cat /opt/quorum/info/num-makers.txt)
MAKERS=()
for index in $(seq 0 $(expr $NUM_MAKERS - 1))
do
    MAKERS[$index]="$(vault read -field=address quorum/makers/$index)"
done

NUM_VALIDATORS=$(cat /opt/quorum/info/num-validators.txt)
VALIDATORS=()
for index in $(seq 0 $(expr $NUM_VALIDATORS - 1))
do
    VALIDATORS[$index]="$(vault read -field=address quorum/validators/$index)"
done

# Generate the quorum config and genesis now that we have all the info we need
VOTE_THRESHOLD=$(cat /opt/quorum/info/vote-threshold.txt)
python /opt/quorum/bin/generate-quorum-config.py --makers ${MAKERS[@]} --validators ${VALIDATORS[@]} --vote-threshold $VOTE_THRESHOLD
(cd /opt/quorum/private && quorum-genesis)

# Make sure genesis file exists before continuing
until [ -e /opt/quorum/private/quorum-genesis.json ]
do
    sleep 1
done

# Initialize geth to run on the quorum network
geth init /opt/quorum/private/quorum-genesis.json

# Run Constellation
# TODO: Boot Automatically Instead
sudo mv /opt/quorum/private/constellation-supervisor.conf /home/ubuntu
#sudo supervisorctl reread
#sudo supervisorctl update

# Sleep to let constellation-node start
#sleep 60

# Generate supervisor config to run quorum
generate_quorum_supervisor_config $ADDRESS $GETH_PW $PRIVATE_IP $ROLE $NUM_MAKERS /opt/quorum/constellation/config.conf

# TODO: Remove after booting automatically
sudo mv /etc/supervisor/conf.d/quorum-supervisor.conf /home/ubuntu/

# Remove the config that runs this and run quorum
sudo rm /etc/supervisor/conf.d/init-quorum-supervisor.conf
sudo supervisorctl reread
sudo supervisorctl update
