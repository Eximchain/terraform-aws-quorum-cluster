#!/bin/bash
set -eu -o pipefail

sudo apt-get remove -y supervisor
sudo easy_install supervisor
sudo mkdir /etc/supervisor/conf.d
