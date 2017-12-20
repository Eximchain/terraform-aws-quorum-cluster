#!/bin/bash
set -eu -o pipefail

VERSION=0.9.0
RELEASE=vault_0.9.0_linux_amd64.zip

wget https://releases.hashicorp.com/vault/$VERSION/$RELEASE
unzip $RELEASE
sudo mv vault /usr/local/bin
