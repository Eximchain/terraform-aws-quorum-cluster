#!/usr/bin/env python

import json
import sys

NETWORK_ID = ''
AWS_ACCOUNT_ID = ''
SETUP_FILE = ''
OUTPUT_DIR = ''

def policy_string(region, role, role_index, cluster_index):
    if role == "bootnodes":
        return """\
path \\"quorum/bootnodes/passwords/{0}/{1}\\" {{
    capabilities = [\\"create\\", \\"update\\", \\"read\\"]
}}

path \\"quorum/bootnodes/keys/{0}/{1}\\" {{
    capabilities = [\\"create\\", \\"update\\", \\"read\\"]
}}

path \\"quorum/bootnodes/addresses/{0}/{1}\\" {{
    capabilities = [\\"create\\", \\"update\\", \\"read\\"]
}}
""".format(region, role_index)
    else:
        return """\
path \\"quorum/passwords/{0}/{1}\\" {{
    capabilities = [\\"create\\", \\"update\\", \\"read\\"]
}}

path \\"quorum/keys/{0}/{1}\\" {{
    capabilities = [\\"create\\", \\"update\\", \\"read\\"]
}}

path \\"quorum/addresses/{0}/{1}\\" {{
    capabilities = [\\"create\\", \\"update\\", \\"read\\"]
}}

path \\"quorum/{2}/{0}/{3}\\" {{
    capabilities = [\\"create\\", \\"update\\", \\"read\\"]
}}
""".format(region, cluster_index, role, role_index)

def write_all_role_nodes(region, role, node_count, start_index):
    for (role_index, cluster_index) in zip(range(node_count),range(start_index, start_index+node_count)):
        node_rolename = "quorum-{0}-network-{1}-{2}-{3}".format(region, NETWORK_ID, role, role_index)
        with open(SETUP_FILE, "a") as f:
            policy_text = policy_string(region, role, role_index, cluster_index)
            f.write("\necho \"{1}\" | vault policy-write {0} - \n".format(node_rolename, policy_text))
            f.write("vault write auth/aws/role/{0} auth_type=iam policies=\"base-read,{0}\" bound_iam_principal_arn=arn:aws:iam::{1}:role/{0} || true \n".format(node_rolename, AWS_ACCOUNT_ID))

if __name__ == "__main__":
    (
        regions_txt,
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
    with open(regions_txt, 'r') as f:
        REGIONS = [line.rstrip('\n') for line in f]

    for REGION in REGIONS:
        NUM_BOOTNODES = int(BOOTNODE_COUNTS[REGION])
        NUM_MAKERS = int(MAKER_COUNTS[REGION])
        NUM_VALIDATORS = int(VALIDATOR_COUNTS[REGION])
        NUM_OBSERVERS = int(OBSERVER_COUNTS[REGION])
        write_all_role_nodes(REGION, 'bootnodes', NUM_BOOTNODES, 0)
        write_all_role_nodes(REGION, 'makers', NUM_MAKERS, 0)
        write_all_role_nodes(REGION, 'validators', NUM_VALIDATORS, NUM_MAKERS)
        write_all_role_nodes(REGION, 'observers', NUM_OBSERVERS, NUM_MAKERS + NUM_VALIDATORS)
