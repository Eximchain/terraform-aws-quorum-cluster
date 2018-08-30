#!/bin/bash
set -eu -o pipefail

# TODO: Reset address to Exim fork, checkout release
# VERSION=v1.5.2

git clone https://github.com/john-osullivan/exim-genesis.git /opt/quorum/lib/quorum-genesis
# git clone https://github.com/Eximchain/quorum-genesis.git /opt/quorum/lib/quorum-genesis
cd /opt/quorum/lib/quorum-genesis
# git checkout tags/$VERSION
sudo npm install -g -y
