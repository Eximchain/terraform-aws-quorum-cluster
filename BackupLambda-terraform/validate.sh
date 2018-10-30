#!/bin/bash
. ./copy.sh
pushd $BASEDIR
terraform validate

