#!/bin/bash
set -eu -o pipefail

VER=v0.4.19
DIR_NAME=solidity_0.4.19

wget https://github.com/ethereum/solidity/releases/download/$VER/$DIR_NAME.tar.gz
tar -xzf $DIR_NAME.tar.gz
cd $DIR_NAME
mkdir build
cd build
cmake .. && make
sudo mv solc/solc /usr/local/bin/
sudo chmod 0755 /usr/local/bin/solc
cd ../.. && rm -rf $DIR_NAME.tar.gz $DIR_NAME
