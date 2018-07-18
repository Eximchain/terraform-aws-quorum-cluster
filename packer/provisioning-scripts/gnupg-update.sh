#!/bin/bash
set -eu -o pipefail

# VERSIONS TO USE
GNUPG_VER="2.2.9"
LIBGPG_VER="1.32"
LIBGCRYPT_VER="1.8.3"
LIBKSBA_VER="1.3.5"
LIBASSUAN_VER="2.5.1"
NPTH_VER="1.6"
PINENTRY_VER="1.1.0"
NCURSES_VER="6.1"
NTBTLS_VER="0.1.2"

GNUPG="gnupg-$GNUPG_VER"
LIBGPG="libgpg-error-$LIBGPG_VER"
LIBGCRYPT="libgcrypt-$LIBGCRYPT_VER"
LIBKSBA="libksba-$LIBKSBA_VER"
LIBASSUAN="libassuan-$LIBASSUAN_VER"
NPTH="npth-$NPTH_VER"
PINENTRY="pinentry-$PINENTRY_VER"
NCURSES="ncurses-$NCURSES_VER"
NTBTLS="ntbtls-$NTBTLS_VER"

function install_libgpg_error {
  wget -c ftp://ftp.gnupg.org/gcrypt/libgpg-error/$LIBGPG.tar.bz2
  tar -xjf $LIBGPG.tar.bz2
  cd $LIBGPG
  ./configure
  make
  sudo make install
  cd ..
}

function install_libgcrypt {
  wget -c ftp://ftp.gnupg.org/gcrypt/libgcrypt/$LIBGCRYPT.tar.gz
  tar -xzf $LIBGCRYPT.tar.gz
  cd $LIBGCRYPT
  ./configure
  make
  sudo make install
  cd ..
}

function install_libassuan {
  wget -c ftp://ftp.gnupg.org/gcrypt/libassuan/$LIBASSUAN.tar.bz2
  tar -xjf $LIBASSUAN.tar.bz2
  cd $LIBASSUAN
  ./configure
  make
  sudo make install
  cd ..
}

function install_libksba {
  wget -c ftp://ftp.gnupg.org/gcrypt/libksba/$LIBKSBA.tar.bz2
  tar -xjf $LIBKSBA.tar.bz2
  cd $LIBKSBA
  ./configure
  make
  sudo make install
  cd ..
}

function install_npth {
  wget -c ftp://ftp.gnupg.org/gcrypt/npth/$NPTH.tar.bz2
  tar -xjf $NPTH.tar.bz2
  cd $NPTH
  ./configure
  make
  sudo make install
  cd ..
}

function install_ncurses {
  wget -c ftp://ftp.gnu.org/gnu/ncurses/$NCURSES.tar.gz
  tar -xzf $NCURSES.tar.gz
  cd $NCURSES
  ./configure
  make
  sudo make install
  cd ..
}

function install_pinentry {
  wget -c ftp://ftp.gnupg.org/gcrypt/pinentry/$PINENTRY.tar.bz2
  tar -xjf $PINENTRY.tar.bz2
  cd $PINENTRY
  ./configure --enable-pinentry-curses --disable-pinentry-qt4
  make
  sudo make install
  cd ..
}

function install_ntbtls {
  wget -c ftp://ftp.gnupg.org/gcrypt/ntbtls/$NTBTLS.tar.bz2
  tar -xjf $NTBTLS.tar.bz2
  cd $NTBTLS
  ./configure
  make
  sudo make install
  cd ..
}

function install_gnupg {
  wget -c ftp://ftp.gnupg.org/gcrypt/gnupg/$GNUPG.tar.bz2
  tar -xjf $GNUPG.tar.bz2
  cd $GNUPG
  ./configure
  make
  sudo make install
  cd ..
}

# Dependencies
install_libgpg_error
install_libgcrypt
install_libassuan
install_libksba
install_npth
install_ncurses
install_pinentry
install_ntbtls

# GNUPG
install_gnupg

# Configure library links
echo "/usr/local/lib" | sudo tee -a /etc/ld.so.conf.d/gpg2.conf
sudo ldconfig -v
