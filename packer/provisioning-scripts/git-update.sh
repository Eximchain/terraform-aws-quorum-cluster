#!/bin/bash
set -eu -o pipefail

RELEASE="v2.18.0"

git clone https://github.com/git/git.git
pushd git >/dev/null
git checkout $RELEASE
make
sudo make install
popd >/dev/null
rm -rf git
