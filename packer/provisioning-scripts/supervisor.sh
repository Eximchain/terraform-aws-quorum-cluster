#!/bin/bash
set -eu -o pipefail

sudo easy_install supervisor

sudo mkdir -p /etc/supervisor/conf.d
sudo mkdir -p /var/log/supervisor
sudo cp /tmp/supervisord.conf /etc/supervisor/supervisord.conf
