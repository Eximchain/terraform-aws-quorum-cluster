#!/bin/bash
set -eu -o pipefail

RELEASE="v239-modified"

git clone https://github.com/Eximchain/systemd.git
pushd systemd >/dev/null
git checkout $RELEASE
meson build
ninja -C build
sudo ninja -C build install
popd >/dev/null
