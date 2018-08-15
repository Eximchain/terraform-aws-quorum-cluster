#!/bin/bash
set -eu -o pipefail

wget -O /tmp/foxpass_setup.py https://raw.githubusercontent.com/foxpass/foxpass-setup/master/linux/ubuntu/16.04/foxpass_setup.py
sudo mv /tmp/foxpass_setup.py /opt/foxpass_setup.py
