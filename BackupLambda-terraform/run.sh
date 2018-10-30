#!/bin/bash
date
. ./copy.sh
pushd $BASEDIR
time terraform apply -auto-approve > /tmp/terraform-apply.txt
date
