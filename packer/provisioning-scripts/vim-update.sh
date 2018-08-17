#!/bin/bash
set -eu -o pipefail

RELEASE="v8.1.0289"

# Remove old version
sudo apt-get remove -y vim

git clone https://github.com/vim/vim.git
pushd vim >/dev/null
git checkout $RELEASE
make
sudo make install
popd >/dev/null
rm -rf vim
