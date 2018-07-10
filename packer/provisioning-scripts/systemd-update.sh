#!/bin/bash
set -eu -o pipefail

RELEASE="v234"

git clone https://github.com/systemd/systemd.git
pushd systemd >/dev/null
git checkout $RELEASE
# Build process for version <= v234
./autogen.sh
./configure
make
sudo make install
# Build process for version >= v235
#meson build
#ninja -C build
#sudo ninja -C build install
popd >/dev/null
