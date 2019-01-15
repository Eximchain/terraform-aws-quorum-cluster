import argparse
import boto3
from botocore.exceptions import ClientError
import os.path
import sys
import urllib2
import xmlrpclib

from ethjsonrpc import EthJsonRpc

# max size in bytes before uploading in parts. between 1 and 5 GB recommended
MAX_SIZE = 50 * 1000 * 1000
# size of parts when uploading in parts
PART_SIZE = 6 * 1000 * 1000


CHAIN_DATA_DIR = '/home/ubuntu/.exim/exim/chaindata/'

EXIM_SUPERVISOR_PROCESS = 'quorum'
EXIM_PORT = 22000

BACKUP_BUCKET_FILE = '/opt/quorum/info/data-backup-bucket.txt'

hostname = urllib2.urlopen("http://169.254.169.254/latest/meta-data/public-hostname").read()

supervisor_client = xmlrpclib.Server('http://localhost:9001/RPC2').supervisor
s3 = boto3.resource('s3')
eth_client = EthJsonRpc(hostname, EXIM_PORT)

def parse_args():
    parser = argparse.ArgumentParser(description='Back up and restore chain data')
    subparsers = parser.add_subparsers(dest='command', help='Command to execute')
    parser_backup = subparsers.add_parser('backup', help='Back up data from this node')
    parser_backup.add_argument('--force', action='store_true', default=False)
    parser_backup.add_argument('--bucket', dest='bucket_id', help='Specify an alternate AWS S3 bucket ID to backup to')
    parser_restore = subparsers.add_parser('restore', help='Restore data from s3')
    parser_restore.add_argument('--block', required=True, type=int, dest='block_to_restore')
    parser_restore.add_argument('--bucket', dest='bucket_id', help='Specify an alternate AWS S3 bucket ID to restore from')
    return parser.parse_args()

def pause_exim():
    supervisor_client.stopProcess(EXIM_SUPERVISOR_PROCESS)
    print 'Exim Paused'

def resume_exim():
    supervisor_client.startProcess(EXIM_SUPERVISOR_PROCESS)
    print 'Exim Resumed'

def s3_upload(bucket_name, source_dir, dest_dir):
    upload_file_names = []
    for (source_dir, dirname, filename) in os.walk(source_dir):
        upload_file_names.extend(filename)
        break

    for filename in upload_file_names:
        sourcepath = os.path.join(source_dir + filename)
        destpath = os.path.join(dest_dir, filename)
        object = s3.Object(bucket_name, destpath)
        print 'Uploading %s to Amazon S3 bucket %s' % (sourcepath, bucket_name)

        filesize = os.path.getsize(sourcepath)
        if filesize > MAX_SIZE:
            print "multipart upload"
            mp = object.initiate_multipart_upload()
            part_num = 0
            parts = []
            with open(sourcepath,'rb') as fp:
                try:
                    while (fp.tell() < filesize):
                        part_num += 1
                        data = fp.read(PART_SIZE)
                        print "uploading part %i (Bytes Uploaded: %d / %d)" % (part_num, fp.tell(), filesize)
                        part = mp.Part(part_num).upload(Body=data)
                        parts.append({"PartNumber": part_num, "ETag": part["ETag"]})
                except Exception as e:
                    print "multipart upload FAILED for %s" % (sourcepath)
                    print e
                    mp.abort()
                else:
                    mp.complete(MultipartUpload={'Parts': parts})

        else:
            print "singlepart upload"
            try:
                object.upload_file(sourcepath)
            except Exception as e:
                print "singlepart upload FAILED for %s" % (sourcepath)
                print e

def s3_download(bucket_name, source_dir, dest_dir):
    bucket = s3.Bucket(bucket_name)
    objects = bucket.objects.all()
    objects_to_copy = filter(lambda obj: obj.key.startswith(source_dir), objects)
    if not objects_to_copy:
        print "No objects found to download"
        return
    for object_summary in objects_to_copy:
        object = object_summary.Object()
        key_without_prefix = object.key.split('/')[-1]
        destpath = dest_dir + key_without_prefix
        print 'Downloading %s from Amazon S3 bucket %s' % (destpath, bucket_name)
        object.download_file(destpath)

def backup_chain_data(backup_bucket, block_number):
    dest_dir = 'block-%s/' % (block_number)
    print 'Backing up chain at block %s' % (block_number)
    try:
        s3_upload(backup_bucket, CHAIN_DATA_DIR, dest_dir)
    except ClientError as e:
        if e.response.get('Error', {}).get('Code') == 'UnauthorizedOperation':
            print("\n>> Permissions Error: It looks like the IAM role attached to this instance does not have permission to upload to your specified S3 bucket.  Please update the role's policy and try again.\n")
        raise


def restore_chain_data(backup_bucket, block_number):
    source_dir = 'block-%s/' % (block_number)
    print 'Restoring chain from block %s' % (block_number)
    try:
        s3_download(backup_bucket, source_dir, CHAIN_DATA_DIR)
    except ClientError as e:
        if e.response.get('Error', {}).get('Code') == 'UnauthorizedOperation':
            print("\n>> Permissions Error: It looks like the IAM role attached to this instance does not have permission to fetch data from the specified S3 bucket.  Please update the role's policy and try again.\n")
        raise

def backup_exists(backup_bucket, block_number):
    prefix = 'block-%s/' % (block_number)
    bucket = s3.Bucket(backup_bucket)
    all_objects = bucket.objects.all()
    backup_objects = filter(lambda obj: obj.key.startswith(prefix), all_objects)
    return len(backup_objects) > 0

# Executes the command specified in the provided argparse namespace
def execute_command(args):
    if args.bucket_id:
        backup_bucket = args.bucket_id
    else:
        with open(BACKUP_BUCKET_FILE, 'r') as f:
            backup_bucket = f.read().strip()
    try:
        if args.command == 'backup':
            current_block = eth_client.eth_blockNumber()
            pause_exim()
            if backup_exists(backup_bucket, current_block):
                if args.force:
                    print 'Backup already found for block %s, OVERWRITING due to --force' % (current_block)
                else:
                    print 'Backup already found for block %s, ABORTING' % (current_block)
                    return
            backup_chain_data(backup_bucket, current_block)
        elif args.command == 'restore':
            pause_exim()
            restore_chain_data(backup_bucket, args.block_to_restore)
    finally:
        resume_exim()

args = parse_args()
execute_command(args)
