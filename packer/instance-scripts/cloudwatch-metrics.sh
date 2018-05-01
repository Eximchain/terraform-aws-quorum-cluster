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

function emit_block_skew_metrics {
  local readonly SKEW_METRIC="BlockSkew"
  local readonly LARGE_SKEW_METRIC="LargeBlockSkew"
  local readonly LARGE_SKEW_LIMIT="100"
  local readonly BLOCK_NUM_METRIC="BlockNumber"
  local readonly PERIOD="600"

  local readonly START_TIME=$(date -Im -u --date='5 minutes ago')
  local readonly END_TIME=$(date -Im -u)

  local readonly RESPONSE_JSON_GLOBAL=$(aws cloudwatch get-metric-statistics --region $PRIMARY_REGION --namespace $NAMESPACE --metric-name $BLOCK_NUM_METRIC --start-time $START_TIME --end-time $END_TIME --dimensions Name=NetworkID,Value=$NETWORK_ID --period $PERIOD --statistics Maximum)
  local readonly MAX_BLOCK=$(echo $RESPONSE_JSON_GLOBAL | jq -r .Datapoints.[0].Maximum | cut -d. -f1)

  local readonly RESPONSE_JSON_LOCAL=$(curl -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' $RPC_ADDR:$RPC_PORT)
  local readonly LOCAL_BLOCK=$(printf "%d" $(echo $RESPONSE_JSON_LOCAL | jq -r .result))

  local readonly SKEW=$(expr $MAX_BLOCK - $LOCAL_BLOCK)

  if [ $SKEW -gt $LARGE_SKEW_LIMIT]
  then
    local LARGE_SKEW="1"
  else
    local LARGE_SKEW="0"
  fi

  aws cloudwatch put-metric-data --region $PRIMARY_REGION --namespace $NAMESPACE --metric-name $SKEW_METRIC --value $SKEW --dimensions NetworkID=$NETWORK_ID
  aws cloudwatch put-metric-data --region $PRIMARY_REGION --namespace $NAMESPACE --metric-name $LARGE_SKEW_METRIC --value $LARGE_SKEW --dimensions NetworkID=$NETWORK_ID
}

while true
do
    emit_pending_transactions_metric
    emit_block_number_metric
    emit_block_skew_metrics
    sleep $SLEEP_SECONDS
done
