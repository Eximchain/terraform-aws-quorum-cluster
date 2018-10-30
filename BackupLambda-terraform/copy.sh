#!/bin/bash
BASEDIR=~/Documents/GitHub/terraform-aws-quorum-cluster/terraform
MODULES="$BASEDIR"/modules
# remove outdated Terraform
rm "$BASEDIR"/variables_override*.tf* "$BASEDIR"/main_override.tf
rm "$MODULES"/quorum-cluster/quorum-cluster-*.tf*
rm "$MODULES"/quorum-cluster-region/quorum-cluster-region*
rm "$MODULES"/quorum-vpc-peering/quorum-vpc-peering-*

cp variables_override*.tf* main_override.tf "$BASEDIR"/
cp quorum-cluster-variables*.tf* quorum-cluster-main_override.tf "$MODULES"/quorum-cluster/
cp quorum-cluster-region* "$MODULES"/quorum-cluster-region/
cp quorum-vpc-peering-* "$MODULES"/quorum-vpc-peering
