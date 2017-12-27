#!/bin/bash
set -eu -o pipefail

VERSION=v1.5.1

git clone https://github.com/Eximchain/quorum-genesis.git /opt/quorum/lib/quorum-genesis
cd /opt/quorum/lib/quorum-genesis
git checkout tags/$VERSION
sudo npm install -g -y
