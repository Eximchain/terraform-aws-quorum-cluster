#!/bin/bash
set -eu -o pipefail

RELEASE="pow-consensus"

git clone https://github.com/Eximchain/quorum-genesis.git /opt/quorum/lib/quorum-genesis
cd /opt/quorum/lib/quorum-genesis
git checkout $RELEASE
sudo npm install -g -y
