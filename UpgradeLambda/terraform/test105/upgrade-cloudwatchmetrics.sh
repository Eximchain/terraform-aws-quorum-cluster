#!/bin/bash
# cloudwatchmetrics

sudo supervisorctl stop cloudwatchmetrics
cp cloudwatch-metrics.sh /opt/quorum/bin/cloudwatch-metrics.sh
chmod 0644 /opt/quorum/bin/cloudwatch-metrics.sh
sudo supervisorctl start cloudwatchmetrics

