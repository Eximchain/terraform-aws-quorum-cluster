#!/bin/bash
set -eu -o pipefail

RELEASE="v1.2.1-modified"

source /etc/profile.d/quorum-custom.sh
git clone https://github.com/Eximchain/quorum.git
pushd quorum >/dev/null
git checkout $RELEASE
make all
sudo cp build/bin/geth /usr/local/bin
sudo cp build/bin/bootnode /usr/local/bin
popd >/dev/null
rm -rf quorum
