#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in server mode. Note that this script assumes it's running in an AMI
# built from the Packer template in examples/vault-consul-ami/vault-consul.json.

set -eu

readonly BASH_PROFILE_FILE="/home/ubuntu/.bash_profile"
readonly VAULT_TLS_CERT_DIR="/opt/vault/tls"
readonly CA_TLS_CERT_FILE="$VAULT_TLS_CERT_DIR/ca.crt.pem"

# This is necessary to retrieve the address for vault
echo "export VAULT_ADDR=https://${vault_dns}:${vault_port}

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

function setup_s3fs {
  echo "${constellation_s3_bucket} /opt/quorum/constellation/private/s3fs fuse.s3fs _netdev,allow_other,iam_role 0 0" | sudo tee /etc/fstab
  sudo mount -a
}

function populate_data_files {
  echo "${index}" | sudo tee /opt/quorum/info/role-index.txt
  echo "${index + overall_index_base}" | sudo tee /opt/quorum/info/overall-index.txt
  echo "${maker_node_count_json}" | sudo tee /opt/quorum/info/maker-counts.json
  echo "${validator_node_count_json}" | sudo tee /opt/quorum/info/validator-counts.json
  echo "${observer_node_count_json}" | sudo tee /opt/quorum/info/observer-counts.json
  echo "${bootnode_count_json}" | sudo tee /opt/quorum/info/bootnode-counts.json
  echo "${role}" | sudo tee /opt/quorum/info/role.txt
  echo "${vote_threshold}" | sudo tee /opt/quorum/info/vote-threshold.txt
  echo "${min_block_time}" | sudo tee /opt/quorum/info/min-block-time.txt
  echo "${max_block_time}" | sudo tee /opt/quorum/info/max-block-time.txt
  echo "${gas_limit}" | sudo tee /opt/quorum/info/gas-limit.txt
  echo "${aws_region}" | sudo tee /opt/quorum/info/aws-region.txt
  echo "${primary_region}" | sudo tee /opt/quorum/info/primary-region.txt
  echo "${generate_metrics}" | sudo tee /opt/quorum/info/generate-metrics.txt
  echo "${data_backup_bucket}" | sudo tee /opt/quorum/info/data-backup-bucket.txt
  echo "${network_id}" | sudo tee /opt/quorum/info/network-id.txt

  sudo python /opt/quorum/bin/fill-node-counts.py --quorum-info-root '/opt/quorum/info'
}

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

sudo apt-get -y update
sudo ntpd

download_vault_certs
setup_s3fs
populate_data_files

# These variables are passed in via Terraform template interpolation
/opt/consul/bin/run-consul --client --cluster-tag-key "${consul_cluster_tag_key}" --cluster-tag-value "${consul_cluster_tag_value}"

/opt/quorum/bin/generate-run-init-quorum ${vault_dns} ${vault_port}
/opt/quorum/bin/run-init-quorum
