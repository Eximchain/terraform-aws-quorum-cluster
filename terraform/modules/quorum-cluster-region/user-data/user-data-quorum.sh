#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in server mode. Note that this script assumes it's running in an AMI
# built from the Packer template in examples/vault-consul-ami/vault-consul.json.

set -eu

readonly BASH_PROFILE_FILE="/etc/profile.d/quorum-custom.sh"
readonly GETH_IPC_PATH_LOCAL="/home/ubuntu/.ethereum/geth.ipc"
readonly VAULT_TLS_CERT_DIR="/opt/vault/tls"
readonly CA_TLS_CERT_FILE="$VAULT_TLS_CERT_DIR/ca.crt.pem"

# This is necessary to retrieve the address for vault
echo '' | sudo tee -a $BASH_PROFILE_FILE
echo "export VAULT_ADDR=https://${vault_dns}:${vault_port}
export GETH_IPC_PATH=$GETH_IPC_PATH_LOCAL
export GETH_IPC=ipc:$GETH_IPC_PATH_LOCAL

function pause-geth {
  sudo supervisorctl stop quorum
}

function resume-geth {
  sudo supervisorctl start quorum
}" | sudo tee -a $BASH_PROFILE_FILE
source $BASH_PROFILE_FILE

sleep 60

function download_vault_certs {
  # Download vault certs from s3
  aws configure set s3.signature_version s3v4
  while [ -z "$(aws s3 ls s3://${vault_cert_bucket}/ca.crt.pem)" ]
  do
      echo "S3 object not found, waiting and retrying"
      sleep 5
  done
  while [ -z "$(aws s3 ls s3://${vault_cert_bucket}/vault.crt.pem)" ]
  do
      echo "S3 object not found, waiting and retrying"
      sleep 5
  done
  aws s3 cp s3://${vault_cert_bucket}/ca.crt.pem $VAULT_TLS_CERT_DIR
  aws s3 cp s3://${vault_cert_bucket}/vault.crt.pem $VAULT_TLS_CERT_DIR

  # Set ownership and permissions
  sudo chown ubuntu $VAULT_TLS_CERT_DIR/*
  sudo chmod 600 $VAULT_TLS_CERT_DIR/*
  sudo /opt/vault/bin/update-certificate-store --cert-file-path $CA_TLS_CERT_FILE
}

function setup_mounts {
  echo "${constellation_s3_bucket} /opt/quorum/constellation/private/s3fs fuse.s3fs _netdev,allow_other,iam_role 0 0" | sudo tee /etc/fstab
  if [ "${efs_fs_id}" != "" ]
  then
    echo "${efs_fs_id}:/ /opt/quorum/mnt/efs efs defaults,_netdev 0 0" | sudo tee -a /etc/fstab
  fi
  sudo mount -a

  # Give ownership back to the user running geth
  sudo chown ubuntu /opt/quorum/mnt/efs
}

function configure_threatstack_agent_if_key_provided {
  if [ "${threatstack_deploy_key}" != "" ]
  then
    echo "{
      \"deploy-key\": \"${threatstack_deploy_key}\",
      \"ruleset\": \"Base Rule Set\",
      \"agent_type\": \"i\"
}" | sudo tee /opt/threatstack/config.json
  fi
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

function setup_foxpass_if_specified {
  if [ "${foxpass_base_dn}" != "" ] && [ "${foxpass_bind_user}" != "" ] && [ "${foxpass_bind_pw}" != "" ] && [ "${foxpass_api_key}" != "" ]
  then
    echo "Foxpass variables specified. Running foxpass_setup.py."
    sudo python3 /opt/foxpass_setup.py --base-dn ${foxpass_base_dn} --bind-user ${foxpass_bind_user} --bind-pw ${foxpass_bind_pw} --api-key ${foxpass_api_key}
    echo "Disabling login by default user"
    printf "\n# Disable default user login\nDenyUsers ubuntu\n" | sudo tee -a /etc/ssh/sshd_config
    sudo systemctl restart sshd
  else
    echo "Foxpass variables not specified."
  fi
}

function populate_data_files {
  local readonly NODE_COUNT_DIR="/opt/quorum/info/"

  echo "${index}" | sudo tee /opt/quorum/info/role-index.txt
  echo "${role}" | sudo tee /opt/quorum/info/role.txt
  echo "${vote_threshold}" | sudo tee /opt/quorum/info/vote-threshold.txt
  echo "${min_block_time}" | sudo tee /opt/quorum/info/min-block-time.txt
  echo "${max_block_time}" | sudo tee /opt/quorum/info/max-block-time.txt
  echo "${max_peers}" | sudo tee /opt/quorum/info/max-peers.txt
  echo "${gas_limit}" | sudo tee /opt/quorum/info/gas-limit.txt
  echo "${aws_region}" | sudo tee /opt/quorum/info/aws-region.txt
  echo "${primary_region}" | sudo tee /opt/quorum/info/primary-region.txt
  echo "${generate_metrics}" | sudo tee /opt/quorum/info/generate-metrics.txt
  echo "${data_backup_bucket}" | sudo tee /opt/quorum/info/data-backup-bucket.txt
  echo "${network_id}" | sudo tee /opt/quorum/info/network-id.txt
  echo "https://${vault_dns}:${vault_port}" | sudo tee /opt/quorum/info/vault-address.txt
  echo "ipc:$GETH_IPC_PATH_LOCAL" | sudo tee /opt/quorum/info/geth-ipc.txt
  echo "${use_elastic_observer_ips}" | sudo tee /opt/quorum/info/using-eip.txt
  echo "${public_ip}" | sudo tee /opt/quorum/info/public-ip.txt
  echo "${eip_id}" | sudo tee /opt/quorum/info/eip-id.txt
  echo "${efs_mt_dns}" | sudo tee /opt/quorum/info/efs-dns.txt
  echo "${efs_fs_id}" | sudo tee /opt/quorum/info/efs-fsid.txt
  echo "${chain_data_dir}" | sudo tee /opt/quorum/info/chain-data-dir.txt
  echo "${geth_verbosity}" | sudo tee /opt/quorum/info/geth-verbosity.txt

  # Download node counts
  aws configure set s3.signature_version s3v4
  aws s3 cp s3://${node_count_bucket}/bootnode-counts.json $NODE_COUNT_DIR
  aws s3 cp s3://${node_count_bucket}/maker-counts.json $NODE_COUNT_DIR
  aws s3 cp s3://${node_count_bucket}/validator-counts.json $NODE_COUNT_DIR
  aws s3 cp s3://${node_count_bucket}/observer-counts.json $NODE_COUNT_DIR

  # Calculate Overall Index
  if [ "${role}" == "maker" ]
  then
    local BASE_INDEX=0
  elif [ "${role}" == "validator" ]
  then
    local BASE_INDEX=$(cat $NODE_COUNT_DIR/maker-counts.json | jq -r '.["${aws_region}"]')
  elif [ "${role}" == "observer" ]
  then
    local REGION_MAKER_COUNT=$(cat $NODE_COUNT_DIR/maker-counts.json | jq -r '.["${aws_region}"]')
    local REGION_VALIDATOR_COUNT=$(cat $NODE_COUNT_DIR/validator-counts.json | jq -r '.["${aws_region}"]')
    local BASE_INDEX=$((REGION_MAKER_COUNT + REGION_VALIDATOR_COUNT))
  else
    echo "Unexpected Role ${role}"
    exit 1
  fi

  local OVERALL_INDEX=$((BASE_INDEX + ${index}))
  echo "$OVERALL_INDEX" | sudo tee /opt/quorum/info/overall-index.txt

  sudo python /opt/quorum/bin/fill-node-counts.py --quorum-info-root '/opt/quorum/info'
}

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Start Supervisor
supervisord -c /etc/supervisor/supervisord.conf

setup_foxpass_if_specified

sudo apt-get -y update
sudo ntpd

download_vault_certs
populate_data_files
setup_mounts

# These variables are passed in via Terraform template interpolation
/opt/consul/bin/run-consul --client --cluster-tag-key "${consul_cluster_tag_key}" --cluster-tag-value "${consul_cluster_tag_value}"

configure_threatstack_agent_if_key_provided
run_threatstack_agent_if_configured

/opt/quorum/bin/generate-run-init-quorum ${vault_dns} ${vault_port}
/opt/quorum/bin/run-init-quorum
