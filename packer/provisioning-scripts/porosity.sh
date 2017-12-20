#!/bin/bash
set -eu -o pipefail

VERSION=v1.2.0

wget -q https://github.com/jpmorganchase/quorum/releases/download/$VERSION/porosity
sudo mv porosity /usr/local/bin && sudo chmod 0755 /usr/local/bin/porosity
