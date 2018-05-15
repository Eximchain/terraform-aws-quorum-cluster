#!/bin/bash
set -eu -o pipefail

readonly DATADIR="/home/ubuntu/.ethereum"
readonly BACKUP_DIR="$DATADIR/geth/chaindata"

readonly BACKUP_BUCKET=$(cat /opt/quorum/info/data-backup-bucket.txt)

function pause_geth {
  sudo mv /etc/supervisor/conf.d/quorum-supervisor.conf /opt/quorum/private/
  sudo supervisorctl reread
  sudo supervisorctl update
}

function resume_geth {
  sudo mv /opt/quorum/private/quorum-supervisor.conf /etc/supervisor/conf.d/
  sudo supervisorctl reread
  sudo supervisorctl update
}

function backup_chain {
  pause_geth
  aws s3 cp --recursive $BACKUP_DIR s3://$BACKUP_BUCKET || true
  resume_geth
}

function restore_chain {
  pause_geth
  aws s3 cp --recursive s3://$BACKUP_BUCKET $BACKUP_DIR || true
  resume_geth
}

function execute_command {
  local readonly CMD=$1

  if [ "$CMD" == "backup" ]
  then
    echo "Backing up current chain"
    backup_chain
    echo "Chain backup complete"
  elif [ "$CMD" == "restore" ]
  then
    echo "Restoring chain from backup"
    restore_chain
    echo "Chain restoration complete"
  else
    echo "Unexpected Command"
    exit 1
  fi
}

readonly COMMAND=$1

execute_command $COMMAND

# TODO: Run in a loop
#while true
#do
#    sleep $SLEEP_SECONDS
#done
