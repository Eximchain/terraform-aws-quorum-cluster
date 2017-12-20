#!/bin/bash
set -eu -o pipefail

cd /tmp

# Primary keys
constellation-node --generatekeys=constellation
# Archival Keys
constellation-node --generatekeys=constellation_a

mv constellation.pub /opt/quorum/constellation/private/
mv constellation.key /opt/quorum/constellation/private/
mv constellation_a.pub /opt/quorum/constellation/private/
mv constellation_a.key /opt/quorum/constellation/private/
