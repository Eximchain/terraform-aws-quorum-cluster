#!/bin/bash
set -eu -o pipefail

# Add Threatstack PGP Key
curl https://app.threatstack.com/APT-GPG-KEY-THREATSTACK | sudo apt-key add -
# Add Threatstack Repository Info
echo "deb https://pkg.threatstack.com/Ubuntu `lsb_release -c | cut -f2` main" | sudo tee /etc/apt/sources.list.d/threatstack.list > /dev/null
# Install the Agent
sudo apt-get update
sudo apt-get install threatstack-agent -y
