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

function complete_constellation_config {
    local AWS_REGION=$1
    local CLUSTER_INDEX=$2
    local HOSTNAME=$3
    local CONSTELLATION_CONFIG_PATH=$4

    local REGIONS=$(cat /opt/quorum/info/regions.txt)

    # Configure constellation with other node IPs
    OTHER_NODES=""
    for region in ${REGIONS[@]}
    do
        local NUM_BOOTNODES=$(cat /opt/quorum/info/bootnode-counts/${region}.txt)
        for index in $(seq 0 $(expr $NUM_BOOTNODES - 1))
        do
            if [[ $index -ne $CLUSTER_INDEX || $region != $AWS_REGION ]]
            then
                BOOTNODE=$(wait_for_successful_command "vault read -field=hostname quorum/bootnodes/addresses/${region}/$index")
                OTHER_NODES="$OTHER_NODES,\"http://$BOOTNODE:9000/\""
            fi
        done
    done
    OTHER_NODES=${OTHER_NODES:1}
    OTHER_NODES_LINE="othernodes = [$OTHER_NODES]"
    echo "$OTHER_NODES_LINE" >> $CONSTELLATION_CONFIG_PATH
    # Configure constellation with URL
    echo "url = \"http://$HOSTNAME:9000/\"" >> $CONSTELLATION_CONFIG_PATH
}

function wait_for_all_bootnodes {
    local REGIONS=$(cat /opt/quorum/info/regions.txt)

    for region in ${REGIONS[@]}
    do
        local NUM_BOOTNODES=$(cat /opt/quorum/info/bootnode-counts/${region}.txt)
        for index in $(seq 0 $(expr $NUM_BOOTNODES - 1))
        do
            wait_for_successful_command "vault read -field=enode quorum/bootnodes/addresses/${region}/$index"
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

function resolve_public_dns_to_ip {

}

# Wait for operator to initialize and unseal vault
wait_for_successful_command 'vault init -check'
wait_for_successful_command 'vault status'

# Wait for vault to be fully configured by the root user
wait_for_successful_command 'vault auth -method=aws'

wait_for_terraform_provisioners

# Get metadata for this instance
INDEX=$(cat /opt/quorum/info/index.txt)
AWS_REGION=$(cat /opt/quorum/info/aws-region.txt)
LB_DNS=$(cat /opt/quorum/info/lb_dns.txt)
BOOT_PORT=30301

# Fetching HOSTNAME
# Old HOSTNAME=$(wait_for_successful_command 'curl http://169.254.169.254/latest/meta-data/public-hostname')
# New: hostname should be contained in the LB_DNS

# Fetching PUBLIC_IP
# Old PUBLIC_IP=$(wait_for_successful_command 'curl http://169.254.169.254/latest/meta-data/public-ipv4')
# Naive: PUBLIC_IP=$(dig +short $LB_DNS)
# Issue: Searching from within same VPC might return private IP instead of public

# Generate bootnode key and construct bootnode address
BOOT_KEY_FILE=/opt/quorum/private/boot.key
BOOT_PUB_FILE=/opt/quorum/private/boot.pub
BOOT_ADDR_FILE=/opt/quorum/private/boot_addr

BOOT_ADDR=$(vault read -field=enode quorum/bootnodes/addresses/$AWS_REGION/$INDEX)
if [ $? -eq 0 ]
then
    # Address already in vault, this is a replacement instance
    CONSTELLATION_PW=$(wait_for_successful_command "vault read -field=constellation_pw qorum/bootnodes/passwords/$AWS_REGION/$INDEX")
    BOOT_PUB=$(wait_for_successful_command "vault read -field=pub_key quorum/bootnodes/addresses/$AWS_REGION/$INDEX")
    BOOT_KEY=$(wait_for_successful_command "vault read -field=bootnode_key quorum/bootnodes/keys/$AWS_REGION/$INDEX")
    echo $BOOT_KEY > $BOOT_KEY_FILE
    echo $BOOT_PUB > $BOOT_PUB_FILE
    echo $BOOT_ADDR > $BOOT_ADDR_FILE
    # Generate constellation key files
    wait_for_successful_command "vault read -field=constellation_pub_key quorum/bootnodes/addresses/$AWS_REGION/$CLUSTER_INDEX" > /opt/quorum/constellation/private/constellation.pub
    wait_for_successful_command "vault read -field=constellation_priv_key quorum/bootnodes/keys/$AWS_REGION/$CLUSTER_INDEX" > /opt/quorum/constellation/private/constellation.key
elif [ -e $BOOT_ADDR_FILE ]
then
    # Address in file but not in vault yet, this is a process restart
    CONSTELLATION_PW=$(wait_for_successful_command "vault read -field=constellation_pw qorum/bootnodes/passwords/$AWS_REGION/$INDEX")
    BOOT_ADDR=$(cat $BOOT_ADDR_FILE)
    BOOT_PUB=$(cat $BOOT_PUB_FILE)
    BOOT_KEY=$(cat $BOOT_KEY_FILE)
    # Generate constellation keys if they weren't generated last run
    if [ ! -e /opt/quorum/constellation/private/constellation.* ]
    then
        echo "$CONSTELLATION_PW" | constellation-node --generatekeys=/opt/quorum/constellation/private/constellation
    fi
else
    # This is a new bootnode
    # Generate and save password first
    # TODO: Make work with nonempty passwords
    CONSTELLATION_PW=""
    wait_for_successful_command "vault write quorum/bootnodes/passwords/$AWS_REGION/$INDEX constellation_pw=$CONSTELLATION_PW"
    BOOT_PUB=$(bootnode --genkey=$BOOT_KEY_FILE --writeaddress)
    BOOT_KEY=$(cat $BOOT_KEY_FILE)
    BOOT_ADDR="enode://$BOOT_PUB@$PUBLIC_IP:$BOOT_PORT"
    echo $BOOT_ADDR > $BOOT_ADDR_FILE
    # Generate constellation keys
    echo "$CONSTELLATION_PW" | constellation-node --generatekeys=/opt/quorum/constellation/private/constellation
fi
CONSTELLATION_PUB_KEY=$(cat /opt/quorum/constellation/private/constellation.pub)
CONSTELLATION_PRIV_KEY=$(cat /opt/quorum/constellation/private/constellation.key)

# Write bootnode address to vault
wait_for_successful_command "vault write quorum/bootnodes/keys/$AWS_REGION/$INDEX bootnode_key=\"$BOOT_KEY\" constellation_priv_key=\"$CONSTELLATION_PRIV_KEY\""
wait_for_successful_command "vault write quorum/bootnodes/addresses/$AWS_REGION/$INDEX enode=$BOOT_ADDR pub_key=$BOOT_PUB hostname=$HOSTNAME constellation_pub_key=$CONSTELLATION_PUB_KEY"

# Wait for all bootnodes to write their address to vault
wait_for_all_bootnodes

# Finish filling in the constellation config
complete_constellation_config $AWS_REGION $INDEX $HOSTNAME /opt/quorum/constellation/config.conf

# Run the bootnode
sudo mv /opt/quorum/private/bootnode-supervisor.conf /etc/supervisor/conf.d/
sudo mv /opt/quorum/private/constellation-supervisor.conf /etc/supervisor/conf.d/
sudo supervisorctl reread
sudo supervisorctl update
