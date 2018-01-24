import argparse
import json

from collections import Counter

def parse_args():
    """
    Parses command line args

    Returns:
        The argparse namespace
    """
    parser = argparse.ArgumentParser(description="Fills in regional node count files from json input")
    parser.add_argument('--quorum-info-root', dest='quorum_info_root', required=True, help="The root of the quorum info dir")
    parser.add_argument('--bootnode', dest='bootnode', action='store_true', help="Whether or not this node is a bootnode")
    return parser.parse_args()

def strip_trailing_slash(path):
    """
    Strips a trailing '/' character from path if it ends with one

    Args:
        path - the path to strip a trailing '/' from

    Returns:
        path without a trailing '/' if it ended with one
     """
    if path[-1] == '/':
        return path[:-1]
    else:
        return path

def write_counts(quorum_info_root, count_type, totals=None, in_totals=None):
    """
    Writes the counts from input JSON to output txt files, adding counts to totals if provided.
    If in_totals is provided, will use that as input JSON instead of reading from the file.

    Args:
        quorum_info_root - The root of the quorum info path retrieved from args
        count_type       - The name of the count. Should be one of 'bootnode-counts', 'maker-counts', 'validator-counts', 'observer-counts', or 'node-counts'
        totals           - A Counter to add running totals to. Should be set for all nodes except bootnodes
        in_totals        - A Counter to use as input json. Should be used for count_type 'node-counts'
    """
    # Get input json
    if in_totals != None:
        in_json = in_totals
    else:
        in_path_template = quorum_info_root + "/%s"
        in_filename = "%s.json" % (count_type)
        in_file_path = in_path_template % (in_filename)

        # Load input file
        with open(in_file_path, 'r') as in_file:
            in_json = {key: int(val) for (key, val) in json.load(in_file).items()}

    # If this is not a bootnode, keep track of total
    if totals != None:
        totals.update(in_json)
    
    # Write to the output .txt files
    out_path_template = quorum_info_root + '/' + count_type + "/%s.txt"
    for region, count in in_json.items():
        out_file_path = out_path_template % (region)
        # Write to the output file
        with open(out_file_path, 'w') as out_file:
            out_file.write(str(count))

def main():
    args = parse_args()
    quorum_info_root = strip_trailing_slash(args.quorum_info_root)

    # Bootnodes, all nodes run this
    write_counts(quorum_info_root, 'bootnode-counts')

    # Other node types, bootnodes skip this
    if not args.bootnode:
        node_totals = Counter()
        write_counts(quorum_info_root, 'maker-counts', totals=node_totals)
        write_counts(quorum_info_root, 'validator-counts', totals=node_totals)
        write_counts(quorum_info_root, 'observer-counts', totals=node_totals)
        write_counts(quorum_info_root, 'node-counts', totals=None, in_totals=node_totals)

if __name__ == '__main__':
    main()
