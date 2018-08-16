#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in client mode and then the run-vault script to configure and start
# Vault in server mode. Note that this script assumes it's running in an AMI built from the Packer template in
# examples/vault-consul-ami/vault-consul.json.

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

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
  else
    echo "Foxpass variables not specified."
  fi
}

function populate_counts {
  echo "${maker_node_count_json}" | sudo tee /opt/vault/data/maker-counts.json
  echo "${validator_node_count_json}" | sudo tee /opt/vault/data/validator-counts.json
  echo "${observer_node_count_json}" | sudo tee /opt/vault/data/observer-counts.json
  echo "${bootnode_count_json}" | sudo tee /opt/vault/data/bootnode-counts.json
}

readonly VAULT_TLS_CERT_DIR="/opt/vault/tls"
readonly CA_TLS_CERT_FILE="$VAULT_TLS_CERT_DIR/ca.crt.pem"
readonly VAULT_TLS_CERT_FILE="$VAULT_TLS_CERT_DIR/vault.crt.pem"
readonly VAULT_TLS_KEY_FILE="$VAULT_TLS_CERT_DIR/vault.key.pem"

# Start Supervisor
supervisord -c /etc/supervisor/supervisord.conf

# The variables below are filled in via Terraform interpolation
/opt/vault/bin/generate-setup-vault.sh ${network_id} "${vault_enterprise_license_key}"

# Download vault certs from s3
aws configure set s3.signature_version s3v4
aws s3 cp s3://${vault_cert_bucket}/ca.crt.pem $VAULT_TLS_CERT_DIR
aws s3 cp s3://${vault_cert_bucket}/vault.crt.pem $VAULT_TLS_CERT_DIR
aws s3 cp s3://${vault_cert_bucket}/vault.key.pem $VAULT_TLS_CERT_DIR

# Save node counts to files for use by generate-setup-vault.sh
populate_counts

# Set ownership and permissions
sudo chown vault:vault $VAULT_TLS_CERT_DIR/*
sudo chmod 600 $VAULT_TLS_CERT_DIR/*
sudo /opt/vault/bin/update-certificate-store --cert-file-path $CA_TLS_CERT_FILE

setup_foxpass_if_specified

configure_threatstack_agent_if_key_provided
run_threatstack_agent_if_configured

/opt/consul/bin/run-consul --client --cluster-tag-key "${consul_cluster_tag_key}" --cluster-tag-value "${consul_cluster_tag_value}"

if [ "${kms_unseal_key_id}" != "" ]
then
  /opt/vault/bin/run-vault --enable-s3-backend --s3-bucket "${s3_bucket_name}" --s3-bucket-region "${aws_region}" --tls-cert-file "$VAULT_TLS_CERT_FILE"  --tls-key-file "$VAULT_TLS_KEY_FILE" --enable-kms-unseal --kms-unseal-key "${kms_unseal_key_id}" --kms-unseal-region "${aws_region}"
else
  /opt/vault/bin/run-vault --enable-s3-backend --s3-bucket "${s3_bucket_name}" --s3-bucket-region "${aws_region}" --tls-cert-file "$VAULT_TLS_CERT_FILE"  --tls-key-file "$VAULT_TLS_KEY_FILE"
fi
