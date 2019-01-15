#!/bin/bash
set -eu -o pipefail

git clone https://github.com/aws/efs-utils.git
cd efs-utils

./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb

cd ..
rm -rf efs-utils
