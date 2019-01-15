import argparse
import boto3
import decimal
import time
import urllib2

from datetime import datetime
from ethjsonrpc import EthJsonRpc

NETWORK_ID_FILE = '/opt/quorum/info/network-id.txt'
with open(NETWORK_ID_FILE, 'r') as f:
    NETWORK_ID = f.read().strip()

AWS_REGION_FILE = '/opt/quorum/info/aws-region.txt'
with open(AWS_REGION_FILE, 'r') as f:
    AWS_REGION = f.read().strip()

PRIMARY_REGION_FILE = '/opt/quorum/info/primary-region.txt'
with open(PRIMARY_REGION_FILE, 'r') as f:
    PRIMARY_REGION = f.read().strip()

EXIM_SUPERVISOR_PROCESS = 'quorum'
DEFAULT_EXIM_PORT = 22000

CLOUDWATCH_NAMESPACE = 'Quorum'
CLOUDWATCH_METRIC = 'NewBlockCreated'

SLEEP_SECONDS = 20

HOSTNAME = urllib2.urlopen("http://169.254.169.254/latest/meta-data/public-hostname").read()

def parse_args():
    parser = argparse.ArgumentParser(description='Emit cloudwatch metrics on block creation')
    parser.add_argument('--network-id', required=True, dest='network_id', help='ID of the network exim is currently connected to')
    parser.add_argument('--rpc-address', default=HOSTNAME, dest='rpc_address', help='Address to reach exim RPC at')
    parser.add_argument('--rpc-port', default=DEFAULT_EXIM_PORT, dest='rpc_port', help='Port to reach exim RPC at')
    return parser.parse_args()

def emit_block_creation_metric(cloudwatch_metric):
    data_point = {
        'MetricName': CLOUDWATCH_METRIC,
        'Dimensions': [
            {
                'Name': 'NetworkID',
                'Value': NETWORK_ID
            },
            {
                'Name': 'Region',
                'Value': AWS_REGION
            }
        ],
        'Timestamp': datetime.utcnow(),
        'Value': 1,
        'Unit': 'None',
        'StorageResolution': 60
    }
    cloudwatch_metric.put_data(MetricData=[data_point])

def update_dynamodb_block_count(dynamodb_table):
    response = dynamodb_table.update_item(
        Key={'Region': AWS_REGION},
        UpdateExpression="ADD NumBlocks :val",
        ExpressionAttributeValues={':val': decimal.Decimal(1)},
        ReturnValues="UPDATED_NEW"
    )

args = parse_args()

cloudwatch = boto3.resource('cloudwatch', region_name=PRIMARY_REGION)
dynamodb = boto3.resource('dynamodb', region_name=PRIMARY_REGION)
eth_client = EthJsonRpc(args.rpc_address, args.rpc_port)

new_block_metric = cloudwatch.Metric(CLOUDWATCH_NAMESPACE, CLOUDWATCH_METRIC)
block_count_table_name = "quorum-net-%s-blocks-by-region" % (args.network_id)
block_count_table = dynamodb.Table(block_count_table_name)

while True:
    try:
        coinbase = eth_client.eth_coinbase()
        block_filter = eth_client.eth_newBlockFilter()
        break
    except:
        print "Error contacting exim node. Waiting %d seconds and retrying." % (SLEEP_SECONDS)
        time.sleep(SLEEP_SECONDS)

while True:
    new_blocks = eth_client.eth_getFilterChanges(block_filter)
    for block_hash in new_blocks:
        block = eth_client.eth_getBlockByHash(block_hash)
        miner = block['miner']
        if miner == coinbase:
            emit_block_creation_metric(new_block_metric)
            update_dynamodb_block_count(block_count_table)

    time.sleep(SLEEP_SECONDS)
