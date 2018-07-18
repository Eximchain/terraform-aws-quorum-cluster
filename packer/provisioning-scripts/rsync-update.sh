#!/bin/bash
set -eu -o pipefail

VER=3.1.3
DIR_NAME=rsync-$VER

wget https://download.samba.org/pub/rsync/src/$DIR_NAME.tar.gz
tar -xzf $DIR_NAME.tar.gz
cd $DIR_NAME
./configure
make
sudo make install
cd ..
rm -rf $DIR_NAME.tar.gz $DIR_NAME
