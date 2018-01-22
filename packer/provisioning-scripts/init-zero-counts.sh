#!/bin/bash
set -eu -o pipefail

QUOR_ROOT=/opt/quorum

REGIONS=$(cat /opt/quorum/info/regions.txt)
COUNT_DIRS=(node-counts bootnode-counts maker-counts validator-counts observer-counts)

for region in ${REGIONS[@]}
do
    for dir in ${COUNT_DIRS[@]}
    do
        echo '0' | sudo tee $QUOR_ROOT/info/$dir/$region.txt
    done
done
