#!/bin/bash
set -eu -o pipefail

readonly SLEEP_SECONDS=60
readonly NAMESPACE="Quorum"

readonly PRIMARY_REGION=$(cat /opt/quorum/info/primary-region.txt)
readonly NETWORK_ID=$(cat /opt/quorum/info/network-id.txt)

readonly RPC_ADDR=$1
readonly RPC_PORT=$2

function emit_rpc_metric {
  local readonly METRIC=$1
  local readonly METHOD=$2
  local readonly JQ_EXPR=$3

  local RESPONSE_JSON=$(curl -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"$METHOD\",\"params\":[],\"id\":1}" $RPC_ADDR:$RPC_PORT)
  local VALUE=$(printf "%d" $(echo $RESPONSE_JSON | jq -r $JQ_EXPR))
  aws cloudwatch put-metric-data --region $PRIMARY_REGION --namespace $NAMESPACE --metric-name $METRIC --value $VALUE --dimensions NetworkID=$NETWORK_ID
}

function emit_pending_transactions_metric {
  local readonly METRIC="PendingQuorumTransactions"
  local readonly METHOD="txpool_status"
  local readonly JQ_EXPR=".result.pending"
  emit_rpc_metric $METRIC $METHOD $JQ_EXPR
}

function emit_block_number_metric {
  local readonly METRIC="BlockNumber"
  local readonly METHOD="eth_blockNumber"
  local readonly JQ_EXPR=".result"
  emit_rpc_metric $METRIC $METHOD $JQ_EXPR
}

while true
do
    emit_pending_transactions_metric
    emit_block_number_metrica
    sleep $SLEEP_SECONDS
done
