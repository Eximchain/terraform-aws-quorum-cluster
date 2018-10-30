#!/bin/bash
. ./copy.sh
pushd $BASEDIR
terraform destroy -auto-approve 
