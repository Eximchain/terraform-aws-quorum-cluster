#!/usr/bin/env python

import json
import sys

def check_role(role):
    if role not in ["makers", "bootnodes", "validators", "observers"]:
        raise ValueError('Only valid roles are "makers", "bootnodes", "validators", or "observers"; instead got "{0}".'.format(role))
    return

def policy_string(region, role, role_index, cluster_index):
    """
    Get the appropriate policy for one node in a given region.

    Args:
        region: String for AWS region (e.g. us-east-1)
        role: One of "bootnodes", "makers", "validators", or "observers".
          Pluralization is important to match Vault paths.
        role_index: Index of this node within all of the nodes in this
          region which are holding the same role (i.e. first validator is 0).
        cluster_index: Index of this node across all nodes in the region,
          irrespective of role (i.e. first validator's index is equal to
          number of makers).

    Returns:
    Return a multi-line string corresponding to the appropriate
    Vault policy for one node in a given region with some role.

    """
    check_role(role)
    if role == "bootnodes":

        return """\
path "quorum/bootnodes/passwords/{0}/{1}" {{
    capabilities = ["create", "update", "read"]
}}

path "quorum/bootnodes/keys/{0}/{1}" {{
    capabilities = ["create", "update", "read"]
}}

path "quorum/bootnodes/addresses/{0}/{1}" {{
    capabilities = ["create", "update", "read"]
}}
""".format(region, role_index)

    else:

        return """\
path "quorum/passwords/{0}/{1}" {{
    capabilities = ["create", "update", "read"]
}}

path "quorum/keys/{0}/{1}" {{
    capabilities = ["create", "update", "read"]
}}

path "quorum/addresses/{0}/{1}" {{
    capabilities = ["create", "update", "read"]
}}

path "quorum/{2}/{0}/{3}" {{
    capabilities = ["create", "update", "read"]
}}
""".format(region, cluster_index, role, role_index)


def write_all_role_nodes(region, role, node_count, start_index):
    """
    Add policies & assignment statements for all nodes with a given
    role in a given region to the SETUP_FILE.  Does not return new
    values, simply modifies SETUP_FILE.

    Args:
        region: String for AWS region (e.g. us-east-1)
        role: One of "bootnodes", "makers", "validators", or "observers".
          Pluralization is important to match Vault paths.
        node_count: Number of nodes with this role, equal to number
          of policy+assignemnt statements added to SETUP_FILE.
        start_index: Start index for these nodes within the region,
          handles non-maker nodes where the cluster_index and role_index
          will be different.
    """
    check_role(role)
    for (role_index, cluster_index) in zip(range(node_count),range(start_index, start_index+node_count)):
        node_rolename = "quorum-{0}-network-{1}-{2}-{3}".format(region, NETWORK_ID, role, role_index)
        with open(SETUP_FILE, "a") as f:
            policy_text = policy_string(region, role, role_index, cluster_index)
            f.write("\necho \'{1}\' | vault policy write {0} - \n".format(node_rolename, policy_text))
            f.write("vault write auth/aws/role/{0} auth_type=iam policies=\"base-read,{0}\" bound_iam_principal_arn=arn:aws:iam::{1}:role/{0} || true \n".format(node_rolename, AWS_ACCOUNT_ID))

NETWORK_ID = ''
AWS_ACCOUNT_ID = ''
SETUP_FILE = ''

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
        bootnode_counts = json.load(f)
    with open(maker_counts_json, 'r') as f:
        maker_counts = json.load(f)
    with open(validator_counts_json, 'r') as f:
        validator_counts = json.load(f)
    with open(observer_counts_json, 'r') as f:
        observer_counts = json.load(f)
    with open(regions_txt, 'r') as f:
        regions = [line.rstrip('\n') for line in f]

    for region in regions:
        num_bootnodes = int(bootnode_counts[region])
        num_makers = int(maker_counts[region])
        num_validators = int(validator_counts[region])
        num_observers = int(observer_counts[region])
        write_all_role_nodes(region, 'bootnodes', num_bootnodes, 0)
        write_all_role_nodes(region, 'makers', num_makers, 0)
        write_all_role_nodes(region, 'validators', num_validators, num_makers)
        write_all_role_nodes(region, 'observers', num_observers, num_makers + num_validators)
