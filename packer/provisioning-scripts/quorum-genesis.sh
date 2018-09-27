#!/bin/bash
set -eu -o pipefail

BRANCH="eximchain"

git clone https://github.com/Eximchain/quorum-genesis.git /opt/quorum/lib/quorum-genesis
cd /opt/quorum/lib/quorum-genesis
git checkout $BRANCH
sudo npm install -g -y
