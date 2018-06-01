import argparse
import boto3
import os.path
import sys
import urllib2
import xmlrpclib

from ethjsonrpc import EthJsonRpc

# max size in bytes before uploading in parts. between 1 and 5 GB recommended
MAX_SIZE = 50 * 1000 * 1000
# size of parts when uploading in parts
PART_SIZE = 6 * 1000 * 1000


CHAIN_DATA_DIR = '/home/ubuntu/.ethereum/geth/chaindata/'

GETH_SUPERVISOR_PROCESS = 'quorum'
GETH_PORT = 22000

BACKUP_BUCKET_FILE = '/opt/quorum/info/data-backup-bucket.txt'
with open(BACKUP_BUCKET_FILE, 'r') as f:
    BACKUP_BUCKET = f.read().strip()

hostname = urllib2.urlopen("http://169.254.169.254/latest/meta-data/public-hostname").read()

supervisor_client = xmlrpclib.Server('http://localhost:9001/RPC2').supervisor
s3 = boto3.resource('s3')
eth_client = EthJsonRpc(hostname, GETH_PORT)

def parse_args():
    parser = argparse.ArgumentParser(description='Back up and restore chain data')
    subparsers = parser.add_subparsers(dest='command', help='Command to execute')
    parser_backup = subparsers.add_parser('backup', help='Back up data from this node')
    parser_restore = subparsers.add_parser('restore', help='Restore data from s3')
    parser_restore.add_argument('--block', required=True, type=int, dest='block_to_restore')
    return parser.parse_args()

def pause_geth():
    supervisor_client.stopProcess(GETH_SUPERVISOR_PROCESS)
    print 'Geth Paused'

def resume_geth():
    supervisor_client.startProcess(GETH_SUPERVISOR_PROCESS)
    print 'Geth Resumed'

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

def backup_chain_data(block_number):
    dest_dir = 'block-%s/' % (block_number)
    print 'Backing up chain at block %s' % (block_number)
    s3_upload(BACKUP_BUCKET, CHAIN_DATA_DIR, dest_dir)

def restore_chain_data(block_number):
    source_dir = 'block-%s/' % (block_number)
    print 'Restoring chain from block %s' % (block_number)
    s3_download(BACKUP_BUCKET, source_dir, CHAIN_DATA_DIR)

args = parse_args()

try:
    if args.command == 'backup':
        current_block = eth_client.eth_blockNumber()
        pause_geth()
        backup_chain_data(current_block)
    elif args.command == 'restore':
        pause_geth()
        restore_chain_data(args.block_to_restore)
finally:
    resume_geth()
