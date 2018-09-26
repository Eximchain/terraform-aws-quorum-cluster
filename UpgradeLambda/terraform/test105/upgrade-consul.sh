#!/bin/bash
# consul

sudo supervisorctl stop consul
cp consul /opt/consul/bin/consul
chmod 0755 /opt/consul/bin/consul
sudo supervisorctl start consul


