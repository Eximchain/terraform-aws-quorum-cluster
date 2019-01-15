#!/bin/bash
set -eu -o pipefail

GOREL=go1.10.3.linux-amd64.tar.gz
BASH_PROFILE=/etc/profile.d/quorum-custom.sh

wget -q https://storage.googleapis.com/golang/$GOREL
tar xfz $GOREL
sudo mv go /usr/local/go
rm -f $GOREL

export GOBIN=/usr/local/go/bin
PATH=$PATH:$GOBIN
printf "\nexport PATH=$GOBIN:$PATH\nexport GOPATH=/usr/local/go\nexport GOBIN=/usr/local/go/bin" | sudo tee -a $BASH_PROFILE

# Install dep
curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
