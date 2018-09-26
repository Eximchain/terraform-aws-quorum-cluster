#!/bin/bash
rm UpgradeLambda &>/dev/null
GOOS="linux" GOARCH="amd64" GOPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/" go build -v eximchain.com/UpgradeLambda
echo "If there are no errors, compiled successfully at `date`!"

