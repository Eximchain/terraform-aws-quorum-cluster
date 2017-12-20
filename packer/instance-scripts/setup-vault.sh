#!/bin/bash
set -eu -o pipefail

# Takes the root token as an argument
# Sets up the vault permissions and deletes the root token when it's done
ROOT_TOKEN=$1

# Authorize with the root token
vault auth $ROOT_TOKEN

# Enable the aws auth backend
vault auth-enable aws

# Enable audit logging
AUDIT_LOG=/opt/vault/log/audit.log
vault audit-enable file file_path=$AUDIT_LOG

# Mount the quorum path
vault mount -path=quorum -default-lease-ttl=30 -description="Keys and Addresses for Quorum Nodes" kv

# Create policies
QUORUM_NODE_POLICY=/opt/vault/config/policies/quorum-node.hcl
vault policy-write quorum_node $QUORUM_NODE_POLICY

# Write policy to the role used by instances
# TODO: Don't hard code bound principal arn
vault write auth/aws/role/quorum-node auth_type=iam policies=quorum_node bound_iam_principal_arn=arn:aws:iam::037794263736:role/quorum-node

# Revoke the root token to reduce security risk
vault token-revoke $ROOT_TOKEN
