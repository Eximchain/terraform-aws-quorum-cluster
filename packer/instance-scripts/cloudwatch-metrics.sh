#!/bin/bash
set -eu -o pipefail

readonly SLEEP_SECONDS=60
readonly NAMESPACE="Quorum"

readonly PRIMARY_REGION=$(cat /opt/quorum/info/primary-region.txt)
readonly NETWORK_ID=$(cat /opt/quorum/info/network-id.txt)

readonly RPC_ADDR=$1
readonly RPC_PORT=$2

function emit_pending_transactions_metric {
  local readonly METRIC="PendingQuorumTransactions"

  RESPONSE_JSON=$(curl -X POST --data '{"jsonrpc":"2.0","method":"txpool_status","params":[],"id":1}' $RPC_ADDR:$RPC_PORT)
  PENDING=$(printf "%d" $(echo $RESPONSE_JSON | jq -r .result.pending))
  aws cloudwatch put-metric-data --region $PRIMARY_REGION --namespace $NAMESPACE --metric-name $METRIC --value $PENDING --dimensions NetworkID=$NETWORK_ID
}

while true
do
    emit_pending_transactions_metric
    sleep $SLEEP_SECONDS
done
