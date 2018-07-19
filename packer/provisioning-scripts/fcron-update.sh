#!/bin/bash
set -eu -o pipefail

VER=3.2.1
DIR_NAME=fcron-$VER

wget http://fcron.free.fr/archives/$DIR_NAME.src.tar.gz
tar -xzf $DIR_NAME.src.tar.gz
cd $DIR_NAME
./configure
make
sudo make install
cd ..
rm -rf $DIR_NAME.src.tar.gz $DIR_NAME
