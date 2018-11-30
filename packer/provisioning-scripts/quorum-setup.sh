#!/bin/bash
set -eu -o pipefail

QUOR_ROOT=/opt/quorum

sudo mkdir $QUOR_ROOT
sudo mkdir $QUOR_ROOT/bin
sudo mkdir $QUOR_ROOT/info
sudo mkdir $QUOR_ROOT/private
sudo mkdir $QUOR_ROOT/log
sudo mkdir $QUOR_ROOT/lib
sudo mkdir $QUOR_ROOT/mnt
sudo mkdir $QUOR_ROOT/mnt/efs
sudo mkdir $QUOR_ROOT/info/node-counts
sudo mkdir $QUOR_ROOT/info/bootnode-counts
sudo mkdir $QUOR_ROOT/info/maker-counts
sudo mkdir $QUOR_ROOT/info/validator-counts
sudo mkdir $QUOR_ROOT/info/observer-counts
sudo mkdir $QUOR_ROOT/constellation
sudo mkdir $QUOR_ROOT/constellation/private
sudo mkdir $QUOR_ROOT/constellation/private/keystore
sudo mkdir $QUOR_ROOT/constellation/private/s3fs

sudo chown -R ubuntu $QUOR_ROOT
sudo chmod -R 777 $QUOR_ROOT
