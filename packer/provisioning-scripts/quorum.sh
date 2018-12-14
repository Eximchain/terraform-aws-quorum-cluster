#!/bin/bash
set -eu -o pipefail

RELEASE="private-transactions"

source /etc/profile.d/quorum-custom.sh
git clone https://github.com/Eximchain/go-ethereum.git
pushd go-ethereum >/dev/null
git checkout $RELEASE
make all
sudo cp build/bin/geth /usr/local/bin
sudo cp build/bin/bootnode /usr/local/bin
popd >/dev/null
rm -rf go-ethereum
