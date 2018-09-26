#!/bin/bash
# constellation

sudo supervisorctl stop constellation
cp constellation-node /usr/local/bin/constellation-node
chmod 0755 /usr/local/bin/constellation-node
sudo supervisorctl start constellation

