#!/bin/bash
set -eu -o pipefail

pkgname=$1

yay -Syu --noconfirm

if [[ $pkgname != ./* ]] && [[ ! -d $pkgname ]]; then
  git clone https://aur.archlinux.org/$pkgname.git
fi

chmod -R a+rw . && chown -R builder:builder .

cd $pkgname
source PKGBUILD

for pkg in ${makedepends[@]} ${depends[@]}; do
  sudo --set-home -u builder yay -S --noconfirm --nouseask --needed --asdeps --overwrite='*' $pkg
done

sudo --set-home -u builder CARCH=$ARCH makepkg -sfA --needed --noconfirm

echo ::set-output name=filelist::$(sudo --set-home -u builder CARCH=$ARCH makepkg --packagelist | xargs)
