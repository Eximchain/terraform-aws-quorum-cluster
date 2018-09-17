#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in server mode. Note that this script assumes it's running in an AMI
# built from the Packer template in examples/vault-consul-ami/vault-consul.json.

set -eu

readonly BASH_PROFILE_FILE="/etc/profile.d/quorum-custom.sh"
readonly VAULT_TLS_CERT_DIR="/opt/vault/tls"
readonly CA_TLS_CERT_FILE="$VAULT_TLS_CERT_DIR/ca.crt.pem"

# This is necessary to retrieve the address for vault
echo "export VAULT_ADDR=https://${vault_dns}:${vault_port}" >> $BASH_PROFILE_FILE
source $BASH_PROFILE_FILE

sleep 60

function download_vault_certs {
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

  echo "${index}" | sudo tee /opt/quorum/info/index.txt
  echo "${aws_region}" | sudo tee /opt/quorum/info/aws-region.txt
  echo "${primary_region}" | sudo tee /opt/quorum/info/primary-region.txt
  echo "${use_elastic_bootnode_ips}" | sudo tee /opt/quorum/info/using-eip.txt
  echo "${public_ip}" | sudo tee /opt/quorum/info/public-ip.txt
  echo "${eip_id}" | sudo tee /opt/quorum/info/eip-id.txt

  # Download node counts
  aws configure set s3.signature_version s3v4
  aws s3 cp s3://${node_count_bucket}/bootnode-counts.json $NODE_COUNT_DIR

  sudo python /opt/quorum/bin/fill-node-counts.py --quorum-info-root '/opt/quorum/info' --bootnode
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

# These variables are passed in via Terraform template interpolation
/opt/consul/bin/run-consul --client --cluster-tag-key "${consul_cluster_tag_key}" --cluster-tag-value "${consul_cluster_tag_value}"

configure_threatstack_agent_if_key_provided
run_threatstack_agent_if_configured

/opt/quorum/bin/generate-run-init-bootnode ${vault_dns} ${vault_port}
/opt/quorum/bin/run-init-bootnode
