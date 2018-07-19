#!/bin/bash
set -eu -o pipefail

DATA_DIR=/opt/vault/data
POLICY_DIR=/opt/vault/config/policies
OUTPUT_FILE=/opt/vault/bin/setup-vault.sh
POLICY_OUTPUT_FILE=/opt/vault/bin/setup-policies.sh
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
vault policy-write base_read \$QUORUM_NODE_POLICY

# Write policy to the roles used by instances
POLICY_DIR=/opt/vault/config/policies
EOF
echo "python write_node_policies.py $DATA_DIR/regions.txt $DATA_DIR/bootnode_counts.json $DATA_DIR/maker_counts.json $DATA_DIR/validator_counts.json $DATA_DIR/observer_counts.json $POLICY_OUTPUT_FILE $NETWORK_ID $AWS_ACCOUNT_ID $POLICY_DIR" >> $OUTPUT_FILE
echo "sudo chown ubuntu $POLICY_OUTPUT_FILE" >> $OUTPUT_FILE
echo "sudo chmod 744 $POLICY_OUTPUT_FILE" >> $OUTPUT_FILE
echo ".$POLICY_OUTPUT_FILE" >> $OUTPUT_FILE

# Old Implementation w/ one role for all quorum & bootnodes
#
# for region in ${REGIONS[@]}
# do
#     QUORUM_ROLE_NAME="quorum-node-$region-network-$NETWORK_ID"
#     BOOTNODE_ROLE_NAME="bootnode-$region-network-$NETWORK_ID"
#     echo "vault write auth/aws/role/$QUORUM_ROLE_NAME auth_type=iam policies=quorum_node bound_iam_principal_arn=arn:aws:iam::$AWS_ACCOUNT_ID:role/$QUORUM_ROLE_NAME || true" >> $OUTPUT_FILE
#     echo "vault write auth/aws/role/$BOOTNODE_ROLE_NAME auth_type=iam policies=quorum_node bound_iam_principal_arn=arn:aws:iam::$AWS_ACCOUNT_ID:role/$BOOTNODE_ROLE_NAME || true" >> $OUTPUT_FILE
# done


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
