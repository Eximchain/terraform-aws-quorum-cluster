#!/bin/bash
set -eu -o pipefail

GOREL=go1.10.3.linux-amd64.tar.gz
BASH_PROFILE=/etc/profile.d/quorum-custom.sh

wget -q https://storage.googleapis.com/golang/$GOREL
tar xfz $GOREL
sudo mv go /usr/local/go
rm -f $GOREL
PATH=$PATH:/usr/local/go/bin
printf "\nexport PATH=/usr/local/go/bin:$PATH" | sudo tee -a $BASH_PROFILE
