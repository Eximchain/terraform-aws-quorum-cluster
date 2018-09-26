#!/bin/bash
# vault

sudo supervisorctl stop vault
cp vault /opt/vault/bin/vault
chmod 0755 /opt/vault/bin/vault
sudo supervisorctl start vault
