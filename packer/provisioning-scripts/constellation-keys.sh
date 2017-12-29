#!/bin/bash
set -eu -o pipefail

cd /tmp

# Primary keys
constellation-node --generatekeys=constellation

mv constellation.pub /opt/quorum/constellation/private/
mv constellation.key /opt/quorum/constellation/private/
