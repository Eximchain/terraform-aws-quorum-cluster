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
  local readonly PARAMS=$3
  local readonly JQ_EXPR=$4

  local RESPONSE_JSON=$(curl -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"$METHOD\",\"params\":[$PARAMS],\"id\":1}" $RPC_ADDR:$RPC_PORT)
  local VALUE=$(printf "%d" $(echo $RESPONSE_JSON | jq -r $JQ_EXPR))
  aws cloudwatch put-metric-data --region $PRIMARY_REGION --namespace $NAMESPACE --metric-name $METRIC --value $VALUE --dimensions NetworkID=$NETWORK_ID
}

function emit_pending_transactions_metric {
  local readonly METRIC="PendingQuorumTransactions"
  local readonly METHOD="txpool_status"
  local readonly PARAMS=''
  local readonly JQ_EXPR=".result.pending"
  emit_rpc_metric "$METRIC" "$METHOD" "$PARAMS" "$JQ_EXPR"
}

function emit_block_number_metric {
  local readonly METRIC="BlockNumber"
  local readonly METHOD="eth_blockNumber"
  local readonly PARAMS=''
  local readonly JQ_EXPR=".result"
  emit_rpc_metric "$METRIC" "$METHOD" "$PARAMS" "$JQ_EXPR"
}

function emit_gas_used_metric {
  local readonly METRIC="LatestBlockGasUsed"
  local readonly METHOD="eth_getBlockByNumber"
  local readonly PARAMS="$1,true"
  local readonly JQ_EXPR=".result.gasUsed"
  emit_rpc_metric "$METRIC" "$METHOD" "$PARAMS" "$JQ_EXPR"
}

function emit_gas_limit_metric {
  local readonly METRIC="LatestBlockGasLimit"
  local readonly METHOD="eth_getBlockByNumber"
  local readonly PARAMS="$1,true"
  local readonly JQ_EXPR=".result.gasLimit"
  emit_rpc_metric "$METRIC" "$METHOD" "$PARAMS" "$JQ_EXPR"
}

function emit_peer_count_metrics {
  local RESPONSE_JSON=$(curl -X POST --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' $RPC_ADDR:$RPC_PORT)
  local VALUE=$(printf "%d" $(echo $RESPONSE_JSON | jq -r .result))

  local NO_PEERS="0"
  local LT_5_PEERS="0"
  local LT_10_PEERS="0"

  if [ $VALUE -lt 1 ]
  then
    NO_PEERS="1"
    LT_5_PEERS="1"
    LT_10_PEERS="1"
  elif [ $VALUE -lt 5 ]
  then
    LT_5_PEERS="1"
    LT_10_PEERS="1"
  elif [ $VALUE -lt 10 ]
  then
    LT_10_PEERS="1"
  fi

  local readonly COUNT_METRIC="PeerCount"
  local readonly NO_PEERS_METRIC="NoPeers"
  local readonly LT_5_PEERS_METRIC="LessThan5Peers"
  local readonly LT_10_PEERS_METRIC="LessThan10Peers"

  aws cloudwatch put-metric-data --region $PRIMARY_REGION --namespace $NAMESPACE --metric-name $COUNT_METRIC --value $VALUE --dimensions NetworkID=$NETWORK_ID
  aws cloudwatch put-metric-data --region $PRIMARY_REGION --namespace $NAMESPACE --metric-name $NO_PEERS_METRIC --value $NO_PEERS --dimensions NetworkID=$NETWORK_ID
  aws cloudwatch put-metric-data --region $PRIMARY_REGION --namespace $NAMESPACE --metric-name $LT_5_PEERS_METRIC --value $LT_5_PEERS --dimensions NetworkID=$NETWORK_ID
  aws cloudwatch put-metric-data --region $PRIMARY_REGION --namespace $NAMESPACE --metric-name $LT_10_PEERS_METRIC --value $LT_10_PEERS --dimensions NetworkID=$NETWORK_ID
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
  local readonly MAX_BLOCK=$(echo $RESPONSE_JSON_GLOBAL | jq -r .Datapoints[0].Maximum | cut -d. -f1)

  local readonly RESPONSE_JSON_LOCAL=$(curl -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' $RPC_ADDR:$RPC_PORT)
  local readonly LOCAL_BLOCK=$(printf "%d" $(echo $RESPONSE_JSON_LOCAL | jq -r .result))

  local readonly SKEW=$(expr $MAX_BLOCK - $LOCAL_BLOCK)

  if [ $SKEW -gt $LARGE_SKEW_LIMIT ]
  then
    local LARGE_SKEW="1"
  else
    local LARGE_SKEW="0"
  fi

  aws cloudwatch put-metric-data --region $PRIMARY_REGION --namespace $NAMESPACE --metric-name $SKEW_METRIC --value $SKEW --dimensions NetworkID=$NETWORK_ID
  aws cloudwatch put-metric-data --region $PRIMARY_REGION --namespace $NAMESPACE --metric-name $LARGE_SKEW_METRIC --value $LARGE_SKEW --dimensions NetworkID=$NETWORK_ID

  if [ $MAX_BLOCK -eq $LOCAL_BLOCK ]
  then
    emit_gas_used_metric $MAX_BLOCK
    emit_gas_limit_metric $MAX_BLOCK
  fi
}

while true
do
    emit_pending_transactions_metric
    emit_block_number_metric
    emit_block_skew_metrics
    emit_peer_count_metrics
    sleep $SLEEP_SECONDS
done
