#!/bin/bash
. ./copy.sh
pushd $BASEDIR
for i in `terraform state list | grep null_resource.BackupLambda`
do
  terraform destroy -target=$i -auto-approve
done 
