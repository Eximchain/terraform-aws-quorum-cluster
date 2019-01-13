#!/bin/bash
set -eu -o pipefail

sudo apt-get update -y
sudo apt-get install -y build-essential cmake libdb-dev libleveldb-dev libboost-all-dev libsodium-dev zlib1g-dev libtinfo-dev sysvbanner wrk git npm automake autotools-dev fuse g++ libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config python-pip ntp libsasl2-dev intltool xsltproc gperf docbook-xsl libcap-dev libmount-dev libgnutls-dev gettext texinfo gnutls-bin sendmail awscli curl unzip jq

# Foxpass Dependencies
sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install libnss-ldapd nscd nslcd
sudo pip install --upgrade pip
sudo pip install boto3 ethjsonrpc

# Add repository for current version of node
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
