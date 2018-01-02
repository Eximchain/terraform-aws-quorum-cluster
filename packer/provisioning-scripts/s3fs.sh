#!/bin/bash
set -eu -o pipefail

git clone https://github.com/s3fs-fuse/s3fs-fuse.git
pushd s3fs-fuse >/dev/null
./autogen.sh
./configure
make
sudo make install
popd >/dev/null
