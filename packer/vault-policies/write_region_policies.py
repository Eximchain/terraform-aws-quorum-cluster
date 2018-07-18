#!/usr/bin/env python

import json

REGION = ''
NETWORK_ID = ''
AWS_ACCOUNT_ID = ''
SETUP_FILE = ''
OUTPUT_DIR = ''
POLICY_DIR = '/opt/vault/config/policies/'

def policy_string(role, role_index, cluster_index):
    if role === "bootnodes":
        return """\
        path "quorum/bootnodes/passwords/{0}/{1}" {
            capabilities = ["create", "update"]
        }

        path "quorum/bootnodes/keys/{0}/{1}" {
            capabilities = ["create", "update"]
        }

        path "quorum/bootnodes/addresses/{0}/{1}" {
            capabilities = ["create", "update"]
        }
        """.format(REGION, role_index)
    else:
        return """\
        path "quorum/passwords/{0}/{1} {
            capabilities = ["create", "update"]
        }

        path "quorum/keys/{0}/{1} {
            capabilities = ["create", "update"]
        }

        path "quorum/addresses/{0}/{1} {
            capabilities = ["create", "update"]
        }

        path "quorum/{2}/{0}/{3} {
            capabilities = ["create", "update"]
        }
        """.format(REGION, cluster_index, role, role_index)

def write_all_role_nodes(role, node_count, start_index):
    for (role_index, cluster_index) in zip(range(node_count),range(start_index, start_index+node_count)):
        node_rolename = "quorum-{0}-network-{1}-{2}-{3}".format(REGION, NETWORK_ID, role, role_index)
        with open(POLICY_DIR+node_rolename+'.hcl', 'w+') as f:
            f.write(policy_string(role, role_index, cluster_index))
        with open(SETUP_FILE, "a") as f:
            f.write("vault policy-write {0} \${1}{0} \n".format(node_rolename, POLICY_DIR))
            f.write("vault write auth/aws/role/{0} auth_type=iam policies=quorum_base,{0} bound_iam_principal_arn=arn:aws:iam::{1}:role/{0} || true \n".format(node_rolename, AWS_ACCOUNT_ID))

if __name__ == "__main__":
    (
        REGION,
        bootnode_counts_json,
        maker_counts_json,
        validator_counts_json,
        observer_counts_json,
        SETUP_FILE,
        NETWORK_ID,
        AWS_ACCOUNT_ID
    ) = sys.argv[1:]

    with open(bootnode_counts_json, 'r') as f:
        BOOTNODE_COUNTS = json.load(f)
    with open(maker_counts_json, 'r') as f:
        MAKER_COUNTS = json.load(f)
    with open(validator_counts_json, 'r') as f:
        VALIDATOR_COUNTS = json.load(f)
    with open(observer_counts_json, 'r') as f:
        OBSERVER_COUNTS = json.load(f)

    NUM_BOOTNODES = BOOTNODE_COUNTS[REGION]
    NUM_MAKERS = MAKER_COUNTS[REGION]
    NUM_VALIDATORS = VALIDATOR_COUNTS[REGION]
    NUM_OBSERVERS = OBSERVER_COUNTS[REGION]
    write_all_role_nodes(REGION, 'bootnodes', NUM_BOOTNODES, 0)
    write_all_role_nodes(REGION, 'makers', NUM_MAKERS, 0)
    write_all_role_nodes(REGION, 'validators', NUM_VALIDATORS, NUM_MAKERS)
    write_all_role_nodes(REGION, 'observers', NUM_OBSERVERS, NUM_MAKERS + NUM_VALIDATORS)
