#!/bin/bash
set -eu -o pipefail

GOREL=go1.10.3.linux-amd64.tar.gz
BASH_PROFILE=/home/ubuntu/.bash_profile

wget -q https://storage.googleapis.com/golang/$GOREL
tar xfz $GOREL
sudo mv go /usr/local/go
rm -f $GOREL
PATH=$PATH:/usr/local/go/bin
echo '' >> /home/ubuntu/.bash_profile
echo 'export PATH=/usr/local/go/bin:$PATH' >> $BASH_PROFILE
