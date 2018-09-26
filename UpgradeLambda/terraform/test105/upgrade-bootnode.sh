#!/bin/bash
# bootnode

sudo supervisorctl stop bootnode
cp bootnode /usr/local/bin/bootnode
chmod 0644 /usr/local/bin/bootnode
sudo supervisorctl start bootnode


