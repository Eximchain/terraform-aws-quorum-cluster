#!/bin/bash
set -eu -o pipefail

OUTPUT_FILE=/opt/vault/bin/setup-vault.sh
AWS_ACCOUNT_ID=$(curl http://169.254.169.254/latest/meta-data/iam/info | jq .InstanceProfileArn | cut -d: -f5)
REGIONS=$(cat /opt/vault/data/regions.txt)

NETWORK_ID=$1

# TODO: Separate permissions of quorum nodes and bootnodes
QUORUM_ROLE_NAME="quorum-node-network-$NETWORK_ID"
BOOTNODE_ROLE_NAME="bootnode-network-$NETWORK_ID"

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

# Create policies
QUORUM_NODE_POLICY=/opt/vault/config/policies/quorum-node.hcl
vault policy-write quorum_node \$QUORUM_NODE_POLICY

# Write policy to the roles used by instances
EOF

for region in ${REGIONS[@]}
do
    # TODO: Separate permissions of quorum nodes and bootnodes
    QUORUM_ROLE_NAME="quorum-node-$region-network-$NETWORK_ID"
    BOOTNODE_ROLE_NAME="bootnode-$region-network-$NETWORK_ID"
    echo "vault write auth/aws/role/$QUORUM_ROLE_NAME auth_type=iam policies=quorum_node bound_iam_principal_arn=arn:aws:iam::$AWS_ACCOUNT_ID:role/$QUORUM_ROLE_NAME || true" >> $OUTPUT_FILE
    echo "vault write auth/aws/role/$BOOTNODE_ROLE_NAME auth_type=iam policies=quorum_node bound_iam_principal_arn=arn:aws:iam::$AWS_ACCOUNT_ID:role/$BOOTNODE_ROLE_NAME || true" >> $OUTPUT_FILE
done

cat << EOF >> $OUTPUT_FILE
# Revoke the root token to reduce security risk
vault token-revoke \$ROOT_TOKEN
EOF

# Give permission to run the script
sudo chown ubuntu $OUTPUT_FILE
sudo chmod 744 $OUTPUT_FILE
