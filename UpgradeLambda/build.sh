#!/bin/bash
# . ./build-go.sh
pushd terraform/test105
terraform init
echo "yes"|terraform destroy && echo "yes"|terraform apply
popd
date
