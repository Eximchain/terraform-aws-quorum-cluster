#!/bin/bash
set -eu -o pipefail

SWAPFILE="/swapfile"
SPACE="4G"
SWAPPINESS="10"

sudo fallocate -l $SPACE $SWAPFILE
sudo chmod 600 $SWAPFILE
sudo mkswap $SWAPFILE

echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab
echo "vm.swappiness=$SWAPPINESS" | sudo tee -a /etc/sysctl.conf
