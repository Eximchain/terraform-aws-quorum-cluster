#!/bin/bash
set -eu -o pipefail

# Remove unnecessary packages with security vulnerabilities
sudo apt-get remove -y unzip bzip2