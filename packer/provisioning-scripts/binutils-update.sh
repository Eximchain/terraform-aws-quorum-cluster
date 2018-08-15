#!/bin/bash
set -eu -o pipefail

VER=2.30
DIR_NAME=binutils-$VER

wget http://ftpmirror.gnu.org/gnu/binutils/$DIR_NAME.tar.gz
tar -xzf $DIR_NAME.tar.gz
cd $DIR_NAME
./configure
make
sudo make install
cd ..
rm -rf $DIR_NAME.tar.gz $DIR_NAME
