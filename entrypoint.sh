#!/bin/bash

pkgname=$1

yay -Syu

useradd builder -m
echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo 'PACKAGER="Misaka13514 <Misaka13514@gmail.com>"
COMPRESSZST=(zstd -19 -c -z -q --threads=0 -)' > /home/builder/.makepkg.conf

if [[ $pkgname != ./* ]];then
  git clone https://aur.archlinux.org/$pkgname.git
fi # 否则为本地包
cd $pkgname
source PKGBUILD

chmod -R a+rw .

for pkg in ${makedepends[@]} ${depends[@]} ;do
  sudo --set-home -u builder yay -S --noconfirm --nouseask --needed --asdeps --overwrite='*' $pkg
done

sudo --set-home -u builder CARCH=$ARCH makepkg -sfA --skipinteg --nodeps --nocheck

echo ::set-output name=filelist::$(sudo --set-home -u builder CARCH=$ARCH makepkg --packagelist | xargs)
