#!/bin/bash
GOOS="linux" 
GOARCH="amd64" 
GOPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/" 
brew instal dep
brew upgrade dep
pushd src/eximchain.com/UpgradeLambda
dep ensure
popd
pushd src/softwareupgrade
dep ensure
popd

