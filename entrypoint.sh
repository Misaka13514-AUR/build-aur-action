#!/bin/bash
set -eu -o pipefail

pkgname=$1

chmod -R a+rw . && chown -R builder:builder .

sudo --set-home -u builder yay -Syu --noconfirm

if [[ $pkgname != ./* ]]; then
  rm -rf $pkgname
  sudo --set-home -u builder git clone https://aur.archlinux.org/$pkgname.git
fi

cd $pkgname
set +u
source PKGBUILD
set -u

for pkg in ${makedepends[@]} ${depends[@]}; do
  sudo --set-home -u builder yay -S --noconfirm --useask=false --needed --asdeps --overwrite='*' $pkg
done

sudo --set-home -u builder CARCH=$ARCH makepkg -sfA --needed --noconfirm

echo ::set-output name=filelist::$(sudo --set-home -u builder CARCH=$ARCH makepkg --packagelist | xargs)
