import argparse
import boto3
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

GETH_SUPERVISOR_PROCESS = 'quorum'
DEFAULT_GETH_PORT = 22000

CLOUDWATCH_NAMESPACE = 'Quorum'
CLOUDWATCH_METRIC = 'NewBlockCreated'

SLEEP_SECONDS = 20

HOSTNAME = urllib2.urlopen("http://169.254.169.254/latest/meta-data/public-hostname").read()

def parse_args():
    parser = argparse.ArgumentParser(description='Emit cloudwatch metrics on block creation')
    parser.add_argument('--rpc-address', default=HOSTNAME, dest='rpc_address', help='Address to reach geth RPC at')
    parser.add_argument('--rpc-port', default=DEFAULT_GETH_PORT, dest='rpc_port', help='Port to reach geth RPC at')
    return parser.parse_args()

args = parse_args()

cloudwatch = boto3.resource('cloudwatch', region_name=PRIMARY_REGION)
eth_client = EthJsonRpc(args.rpc_address, args.rpc_port)

new_block_metric = cloudwatch.Metric(CLOUDWATCH_NAMESPACE, CLOUDWATCH_METRIC)

while True:
    try:
        coinbase = eth_client.eth_coinbase()
        block_filter = eth_client.eth_newBlockFilter()
        break
    except:
        print "Error contacting geth node. Waiting %d seconds and retrying." % (SLEEP_SECONDS)
        time.sleep(SLEEP_SECONDS)

while True:
    new_blocks = eth_client.eth_getFilterChanges(block_filter)
    for block_hash in new_blocks:
        block = eth_client.eth_getBlockByHash(block_hash)
        miner = block['miner']
        if miner == coinbase:
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
            new_block_metric.put_data(MetricData=[data_point])

    time.sleep(SLEEP_SECONDS)
