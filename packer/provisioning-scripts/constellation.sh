#!/bin/bash
set -eu -o pipefail

VER=v0.1.0
DIR_NAME=constellation-0.1.0-ubuntu1604

wget https://github.com/jpmorganchase/constellation/releases/download/$VER/$DIR_NAME.tar.xz
tar -xf $DIR_NAME.tar.xz
sudo cp $DIR_NAME/constellation-node /usr/local/bin && sudo chmod 0755 /usr/local/bin/constellation-node
rm -rf $DIR_NAME.tar.xz $DIR_NAME
