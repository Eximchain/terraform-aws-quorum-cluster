#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in client mode and then the run-vault script to configure and start
# Vault in server mode. Note that this script assumes it's running in an AMI built from the Packer template in
# examples/vault-consul-ami/vault-consul.json.

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

readonly VAULT_TLS_CERT_DIR="/opt/vault/tls"
readonly CA_TLS_CERT_FILE="$VAULT_TLS_CERT_DIR/ca.crt.pem"
readonly VAULT_TLS_CERT_FILE="$VAULT_TLS_CERT_DIR/vault.crt.pem"
readonly VAULT_TLS_KEY_FILE="$VAULT_TLS_CERT_DIR/vault.key.pem"

# The variables below are filled in via Terraform interpolation
/opt/vault/bin/generate-setup-vault.sh ${network_id}

# Download vault certs from s3
aws configure set s3.signature_version s3v4
aws s3 cp s3://${vault_cert_bucket}/ca.crt.pem $VAULT_TLS_CERT_DIR
aws s3 cp s3://${vault_cert_bucket}/vault.crt.pem $VAULT_TLS_CERT_DIR
aws s3 cp s3://${vault_cert_bucket}/vault.key.pem $VAULT_TLS_CERT_DIR

# Set ownership and permissions
sudo chown vault:vault $VAULT_TLS_CERT_DIR/*
sudo chmod 600 $VAULT_TLS_CERT_DIR/*
sudo /opt/vault/bin/update-certificate-store --cert-file-path $CA_TLS_CERT_FILE

/opt/consul/bin/run-consul --client --cluster-tag-key "${consul_cluster_tag_key}" --cluster-tag-value "${consul_cluster_tag_value}"
/opt/vault/bin/run-vault --s3-bucket "${s3_bucket_name}" --s3-bucket-region "${aws_region}" --tls-cert-file "$VAULT_TLS_CERT_FILE"  --tls-key-file "$VAULT_TLS_KEY_FILE"
