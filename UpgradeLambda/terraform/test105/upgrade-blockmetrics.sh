#!/bin/bash
# blockmetrics

sudo supervisorctl stop blockmetrics
cp block-metrics.py /opt/quorum/bin/block-metrics.py
chmod 0644 /opt/quorum/bin/block-metrics.py
sudo supervisorctl start blockmetrics
