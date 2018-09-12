#!/bin/bash
set -eu -o pipefail

DATA_DIR=/opt/vault/data
OUTPUT_FILE=/opt/vault/bin/setup-vault.sh
POLICY_FILE=/opt/vault/bin/setup-policies.sh
AWS_ACCOUNT_ID=$(curl http://169.254.169.254/latest/meta-data/iam/info | jq .InstanceProfileArn | cut -d: -f5)

# Default Arg Values
VAULT_ENTERPRISE_LICENSE_KEY=""
OKTA_ORG_NAME=""
OKTA_ACCESS_GROUP=""
OKTA_BASE_URL="okta.com"
# Parse Required Args
NETWORK_ID=$1
shift # past argument
# Parse Optional Args
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -v|--vault-enterprise-license-key)
    VAULT_ENTERPRISE_LICENSE_KEY="$2"
    shift # past argument
    shift # past value
    ;;
    -o|--okta-org-name)
    OKTA_ORG_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -b|--okta-base-url)
    OKTA_BASE_URL="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--okta-access-group)
    OKTA_ACCESS_GROUP="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    echo "Unexpected Option '$1' Found"
    shift # past argument
    ;;
esac
done

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
QUORUM_NODE_POLICY=/opt/vault/config/policies/base-read.hcl
vault policy-write base-read \$QUORUM_NODE_POLICY
EOF

# Use script to fill out policies file, add command to run it
echo "python /opt/vault/bin/write-node-policies.py $DATA_DIR/regions.txt $DATA_DIR/bootnode-counts.json $DATA_DIR/maker-counts.json $DATA_DIR/validator-counts.json $DATA_DIR/observer-counts.json $POLICY_FILE $NETWORK_ID $AWS_ACCOUNT_ID" >> $OUTPUT_FILE
echo "$POLICY_FILE" >> $OUTPUT_FILE

# Write the enterprise license key if it was provided
if [ "$VAULT_ENTERPRISE_LICENSE_KEY" != "" ]
then
  echo "# Write vault enterprise license key" >> $OUTPUT_FILE
  echo "vault write sys/license text=$VAULT_ENTERPRISE_LICENSE_KEY" >> $OUTPUT_FILE
fi

# Set up Okta auth if enabled
if [ "$OKTA_ORG_NAME" != "" ]
then
  cat << EOF >> $OUTPUT_FILE

# Enable and Configure Okta Access
OKTA_API_TOKEN=\$(sudo cat /opt/vault/data/okta-api-token.txt)
vault auth enable okta
vault write auth/okta/config base_url="$OKTA_BASE_URL" organization="$OKTA_ORG_NAME" token="\$OKTA_API_TOKEN"

# Write policy and assign to a group
vault policy-write quorum-root /opt/vault/config/policies/quorum-root.hcl
vault write auth/okta/groups/$OKTA_ACCESS_GROUP policies=quorum-root
EOF
fi

cat << EOF >> $OUTPUT_FILE
# Revoke the root token to reduce security risk
vault token-revoke \$ROOT_TOKEN
EOF

# Give permission to run the script
sudo chown vault $OUTPUT_FILE
sudo chmod 777 $OUTPUT_FILE

# Ensure $POLICY_FILE exists, make it runnable
cat << EOF > $POLICY_FILE
#!/bin/bash
set -eu -o pipefail

# Will be dynamically populated by write-node-policies.py script
EOF
sudo chown vault $POLICY_FILE
sudo chmod 777 $POLICY_FILE
