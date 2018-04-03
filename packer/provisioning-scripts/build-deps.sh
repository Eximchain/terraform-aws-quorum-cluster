#!/bin/bash
set -eu -o pipefail

sudo apt-get update
sudo apt-get install -y build-essential unzip cmake libdb-dev libleveldb-dev libboost-all-dev libsodium-dev zlib1g-dev libtinfo-dev sysvbanner wrk git npm automake autotools-dev fuse g++ libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config python-pip
sudo pip install boto3
# Add repository for current version of node
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
