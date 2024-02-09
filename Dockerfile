FROM archlinux:base-devel

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

WORKDIR /tmp

COPY pacman.conf pacman32.conf /etc/

RUN pacman-key --init \
    && pacman -Syu --noconfirm yay git \
    && rm -rf /var/cache/pacman/pkg/* \
    && rm -rf /var/lib/pacman/sync/*

RUN useradd builder -m \
    && echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && echo 'PACKAGER="Misaka13514 <Misaka13514@gmail.com>"' >> /etc/makepkg.conf \
    && echo 'COMPRESSZST=(zstd -c -T0 --ultra -20 -)' >> /etc/makepkg.conf

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"] 
