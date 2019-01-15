#!/bin/bash
set -eu -o pipefail

RELEASE="master"

source /etc/profile.d/quorum-custom.sh
cd $GOPATH/src

git clone https://github.com/eximchain/crux.git
cd crux
git checkout $RELEASE
dep ensure
make all
sudo cp bin/crux /usr/local/bin
cd ..
rm -rf crux
