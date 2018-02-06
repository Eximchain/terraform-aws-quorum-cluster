#!/bin/bash
set -eu -o pipefail

SLEEP_SECONDS=60
NAMESPACE="Quorum"
METRIC="PendingQuorumTransactions"

REGION=$(cat /opt/quorum/info/aws-region.txt)
NETWORK_ID=$(cat /opt/quorum/info/network-id.txt)

RPC_ADDR=$1
RPC_PORT=$2

while true
do
    RESPONSE_JSON=$(curl -X POST --data '{"jsonrpc":"2.0","method":"txpool_status","params":[],"id":1}' $RPC_ADDR:$RPC_PORT)
    PENDING=$(printf "%d" $(echo $RESPONSE_JSON | jq -r .result.pending))
    aws cloudwatch put-metric-data --region $REGION --namespace $NAMESPACE --metric-name $METRIC --value $PENDING --dimensions NetworkID=$NETWORK_ID
    sleep $SLEEP_SECONDS
done
