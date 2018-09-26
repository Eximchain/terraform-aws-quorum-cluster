#!/bin/bash
# quorum

sudo supervisorctl stop quorum
cp geth /usr/local/bin/geth
chmod 0755 /usr/local/bin/geth
sudo supervisorctl start quorum
