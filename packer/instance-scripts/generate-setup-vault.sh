#!/bin/bash
set -eu -o pipefail

DATA_DIR=/opt/vault/data
POLICY_DIR=/opt/vault/config/policies/
OUTPUT_FILE=/opt/vault/bin/setup-vault.sh
AWS_ACCOUNT_ID=$(curl http://169.254.169.254/latest/meta-data/iam/info | jq .InstanceProfileArn | cut -d: -f5)

NETWORK_ID=$1
if [ $# -eq 2 ]
then
  VAULT_ENTERPRISE_LICENSE_KEY="$2"
else
  VAULT_ENTERPRISE_LICENSE_KEY=""
fi

# Write the setup-vault script
cat << EOF > $OUTPUT_FILE
#!/bin/bash
set -eu -o pipefail

# Takes the root token as an argument
# Sets up the vault permissions and deletes the root token when it's done
ROOT_TOKEN=\$1

# Authorize with the root token
vault auth \$ROOT_TOKEN

# Enable the aws auth backend
vault auth-enable aws

# Enable audit logging
AUDIT_LOG=/opt/vault/log/audit.log
vault audit-enable file file_path=\$AUDIT_LOG

# Mount the quorum path
vault mount -path=quorum -default-lease-ttl=30 -description="Keys and Addresses for Quorum Nodes" kv

# Create base policy
QUORUM_NODE_POLICY=/opt/vault/config/policies/quorum-node-base.hcl
vault policy-write base-read \$QUORUM_NODE_POLICY

# Write policy to the roles used by instances
POLICY_DIR=/opt/vault/config/policies/
EOF

# Use script to fill out policies file, add command to run it
echo "python /opt/vault/bin/write-node-policies.py $DATA_DIR/regions.txt $DATA_DIR/bootnode-counts.json $DATA_DIR/maker-counts.json $DATA_DIR/validator-counts.json $DATA_DIR/observer-counts.json /opt/vault/bin/setup-policies.sh $NETWORK_ID $AWS_ACCOUNT_ID $POLICY_DIR" >> $OUTPUT_FILE
echo "/opt/vault/bin/setup-policies.sh" >> $OUTPUT_FILE

# Write the enterprise license key if it was provided
if [ "$VAULT_ENTERPRISE_LICENSE_KEY" != "" ]
then
  echo "# Write vault enterprise license key" >> $OUTPUT_FILE
  echo "vault write sys/license text=$VAULT_ENTERPRISE_LICENSE_KEY" >> $OUTPUT_FILE
fi

cat << EOF >> $OUTPUT_FILE
# Revoke the root token to reduce security risk
vault token-revoke \$ROOT_TOKEN
EOF

# Give permission to run the script
sudo chown ubuntu $OUTPUT_FILE
sudo chmod 744 $OUTPUT_FILE
