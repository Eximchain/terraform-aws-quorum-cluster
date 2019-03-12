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

    local DIR=$(dirname "${CONSTELLATION_CONFIG_PATH}")
    local FLAGFILE="$DIR/constellation.done"

    if [ ! -f $FLAGFILE ]
    then
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
        echo `date` "Constellation created"! > $FLAGFILE
    fi
}

function generate_crux_supervisor_config {
  local HOSTNAME=$1

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

  local GRPC_PORT="8090"
  local HTTP_PORT="9000"
  local VERBOSITY="3"

  # TODO: Persistent storage on s3fs or efs
  COMMAND="crux --url=http://$HOSTNAME:$HTTP_PORT/ --networkinterface=0.0.0.0 --port=$HTTP_PORT --grpcport=$GRPC_PORT --workdir=/opt/quorum/constellation --publickeys=private/constellation.pub --privatekeys=private/constellation.key --verbosity=$VERBOSITY"

  if [ "$OTHER_NODES" != "" ]
  then
    COMMAND="$COMMAND --othernodes=$OTHER_NODES"
  fi

  echo "[program:crux]
command=$COMMAND
stdout_logfile=/opt/quorum/log/crux-stdout.log
stderr_logfile=/opt/quorum/log/crux-error.log
numprocs=1
autostart=true
autorestart=unexpected
stopsignal=INT
user=ubuntu" | sudo tee /etc/supervisor/conf.d/crux-supervisor.conf
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

function run_threatstack_agent_if_configured {
  if [ -e /opt/threatstack/config.json ]
  then
    echo "Threatstack agent configuration found. Starting Agent."
    sudo cloudsight setup --config="/opt/threatstack/config.json"
  else
    echo "No Threatstack agent configuration found."
  fi
}


# Wait for operator to initialize and unseal vault
wait_for_successful_command 'vault init -check'
wait_for_successful_command 'vault status'

# Wait for vault to be fully configured by the root user
wait_for_successful_command 'vault auth -method=aws'

# Get metadata for this instance
INDEX=$(cat /opt/quorum/info/index.txt)
AWS_REGION=$(cat /opt/quorum/info/aws-region.txt)
IP_ADDR=$(cat /opt/quorum/info/public-ip.txt)
USING_EIP=$(cat /opt/quorum/info/using-eip.txt)
EIP_ID=$(cat /opt/quorum/info/eip-id.txt)
CLUSTER_INDEX=$(cat /opt/quorum/info/index.txt)
INSTANCE_ID=$(wait_for_successful_command 'curl -s http://169.254.169.254/latest/meta-data/instance-id')
BOOT_PORT=30301

# Associate the EIP with this instance
# TODO: Test or remove now that quorum nodes and bootnodes are in the same VPC.
if [ "$USING_EIP" == "1" ]
then
    wait_for_successful_command "aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id $EIP_ID --region $AWS_REGION --allow-reassociation"
elif [ "$USING_EIP"  == "0" ]
then
    IP_ADDR=$(wait_for_successful_command 'curl -s http://169.254.169.254/latest/meta-data/public-ipv4')
else
    echo ">> FATAL ERROR: USING_EIP needs to be boolean with value 0 or 1, instead has value $USING_EIP.  Erroring out."
    exit 1
fi

# Fetch hostname after EIP association, as that changes hostname value.
HOSTNAME=$(wait_for_successful_command 'curl http://169.254.169.254/latest/meta-data/public-hostname')

# Generate bootnode key and construct bootnode address
BOOT_KEY_FILE=/opt/quorum/private/boot.key
BOOT_PUB_FILE=/opt/quorum/private/boot.pub
BOOT_ADDR_FILE=/opt/quorum/private/boot_addr

BOOT_ADDR=$(vault read -field=enode quorum/bootnodes/addresses/$AWS_REGION/$INDEX)
if [ $? -eq 0 ]
then
    # Address already in vault, this is a replacement instance
    CONSTELLATION_PW=$(wait_for_successful_command "vault read -field=constellation_pw quorum/bootnodes/passwords/$AWS_REGION/$INDEX")
    BOOT_PUB=$(wait_for_successful_command "vault read -field=pub_key quorum/bootnodes/addresses/$AWS_REGION/$INDEX")
    BOOT_KEY=$(wait_for_successful_command "vault read -field=bootnode_key quorum/bootnodes/keys/$AWS_REGION/$INDEX")
    BOOT_ADDR="enode://$BOOT_PUB@$IP_ADDR:$BOOT_PORT"
    echo $BOOT_KEY > $BOOT_KEY_FILE
    echo $BOOT_PUB > $BOOT_PUB_FILE
    echo $BOOT_ADDR > $BOOT_ADDR_FILE
    # Generate constellation key files
    wait_for_successful_command "vault read -field=constellation_pub_key quorum/bootnodes/addresses/$AWS_REGION/$CLUSTER_INDEX" > /opt/quorum/constellation/private/constellation.pub
    wait_for_successful_command "vault read -field=constellation_priv_key quorum/bootnodes/keys/$AWS_REGION/$CLUSTER_INDEX" > /opt/quorum/constellation/private/constellation.key
elif [ -e $BOOT_ADDR_FILE ]
then
    # Address in file but not in vault yet, this is a process restart
    CONSTELLATION_PW=$(wait_for_successful_command "vault read -field=constellation_pw quorum/bootnodes/passwords/$AWS_REGION/$INDEX")
    BOOT_ADDR=$(cat $BOOT_ADDR_FILE)
    BOOT_PUB=$(cat $BOOT_PUB_FILE)
    BOOT_KEY=$(cat $BOOT_KEY_FILE)
    # Generate constellation keys if they weren't generated last run
    if [ ! -e /opt/quorum/constellation/private/constellation.* ]
    then
        crux --generate-keys=/opt/quorum/constellation/private/constellation
    fi
else
    # This is a new bootnode
    # Generate and save password first
    # TODO: Make work with nonempty passwords
    CONSTELLATION_PW=""
    wait_for_successful_command "vault write quorum/bootnodes/passwords/$AWS_REGION/$INDEX constellation_pw=$CONSTELLATION_PW"
    bootnode -genkey=$BOOT_KEY_FILE
    BOOT_PUB=$(bootnode -nodekey=$BOOT_KEY_FILE -writeaddress)
    BOOT_KEY=$(cat $BOOT_KEY_FILE)
    BOOT_ADDR="enode://$BOOT_PUB@$IP_ADDR:$BOOT_PORT"
    echo $BOOT_ADDR > $BOOT_ADDR_FILE
    # Generate constellation keys
    crux --generate-keys=/opt/quorum/constellation/private/constellation
fi
CONSTELLATION_PUB_KEY=$(cat /opt/quorum/constellation/private/constellation.pub)
CONSTELLATION_PRIV_KEY=$(cat /opt/quorum/constellation/private/constellation.key)

# Write bootnode address to vault
wait_for_successful_command "vault write quorum/bootnodes/keys/$AWS_REGION/$INDEX bootnode_key=$BOOT_KEY constellation_priv_key=$CONSTELLATION_PRIV_KEY"
wait_for_successful_command "vault write quorum/bootnodes/addresses/$AWS_REGION/$INDEX enode=$BOOT_ADDR pub_key=$BOOT_PUB hostname=$IP_ADDR constellation_pub_key=$CONSTELLATION_PUB_KEY"
# Wait for all bootnodes to write their address to vault
wait_for_all_bootnodes

# Run the bootnode
sudo mv /opt/quorum/private/bootnode-supervisor.conf /etc/supervisor/conf.d/
# TODO: Enable crux once private transactions work
#generate_crux_supervisor_config $IP_ADDR
sudo supervisorctl reread
sudo supervisorctl update

run_threatstack_agent_if_configured
