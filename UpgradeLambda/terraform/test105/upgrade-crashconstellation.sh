#!/bin/bash
# crashconstellation

sudo supervisorctl stop crashconstellation crashquorum
cp crashcloudwatch.py /opt/quorum/bin/crashcloudwatch.py
chmod 0744 /opt/quorum/bin/crashcloudwatch.py
sudo supervisorctl start crashquorum crashconstellation


