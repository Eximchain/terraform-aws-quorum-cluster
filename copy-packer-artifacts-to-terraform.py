import argparse
import json
import os.path
import shutil

QUORUM_IN_FILE = "packer/manifests/quorum.json"
BOOTNODE_IN_FILE = "packer/manifests/bootnode.json"
VAULT_IN_FILE = "packer/manifests/vault-consul.json"
OUT_FILE = "terraform/amis.auto.tfvars.json"

def parse_args():
    """
    Parses command line args

    Returns:
        The argparse namespace
    """
    parser = argparse.ArgumentParser(description="Copies packer artifacts from the packer manifest output to terraform input variables.")
    parser.add_argument('--tfvars-backup-file', dest='tfvar_backup_file', default=None, help="A file at which to back up the current terraform amis variable.")
    return parser.parse_args()

def get_last_build(packer_manifest):
    """
    Gets the last build from a packer manifest.

    Args:
        packer_manifest: a dictionary representing the packer manifest file loaded by the json library
    Returns:
        A dict representing the JSON object for the last build
    """
    last_run_uuid = packer_manifest['last_run_uuid']
    last_build_list = filter(lambda build: build['packer_run_uuid'] == last_run_uuid, packer_manifest['builds'])
    assert len(last_build_list) == 1
    return last_build_list[0]

def parse_manifest_file(filename):
    """
    Parses artifacts from a manifest file into a mapping from region to AMI.

    Args:
        filename: the manifest file to parse
    Returns:
        A dict mapping region to AMI ID
    """
    with open(filename, 'r') as manifest_file:
        packer_manifest = json.load(manifest_file)

    last_build = get_last_build(packer_manifest)
    artifacts = last_build['artifact_id'].split(',')
    ami_dict = {}
    for artifact in artifacts:
        region, ami = artifact.split(':')
        ami_dict[region] = ami
    return ami_dict

def main():
    args = parse_args()
    # Back up the current output file if a backup location was specified
    if args.tfvar_backup_file and os.path.exists(args.out_file):
        shutil.copyfile(args.out_file, args.tfvar_backup_file)

    quorum_amis = parse_manifest_file(QUORUM_IN_FILE)
    bootnode_amis = parse_manifest_file(BOOTNODE_IN_FILE)
    vault_consul_amis = parse_manifest_file(VAULT_IN_FILE)

    output = {'quorum_amis': quorum_amis, 'bootnode_amis': bootnode_amis}

    if len(vault_consul_amis) == 1:
        output['vault_consul_ami'] = vault_consul_amis.values()[0]
    elif len(vault_consul_amis) == 0:
        print "No vault-consul AMIs found. Only copying quorum and bootnode AMIs."
    else:
        print "Multiple vault-consul AMIs found. Only copying quorum and bootnode AMIs."

    with open(OUT_FILE, 'w') as out_file:
        json.dump(output, out_file, indent=2, separators=(',', ': '))

if __name__ == '__main__':
    main()
