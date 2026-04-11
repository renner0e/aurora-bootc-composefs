#!/bin/bash

set -ouex pipefail

dnf config-manager setopt keepcache=1

dnf -y swap bootc https://kojipkgs.fedoraproject.org//packages/bootc/1.15.0/1.fc44/x86_64/bootc-1.15.0-1.fc44.x86_64.rpm

rm -rf /etc/dnf/protected.d/grub*
dnf -y do --action=install systemd-boot-unsigned --action=remove bootupd grub2-pc

mkdir -p /usr/lib/dracut/dracut.conf.d/
printf "systemdsystemconfdir=/etc/systemd/system\nsystemdsystemunitdir=/usr/lib/systemd/system\n" | tee /usr/lib/dracut/dracut.conf.d/30-bootcrew-fix-bootc-module.conf
printf 'reproducible=yes\nhostonly=no\ncompress=zstd\nadd_dracutmodules+=" bootc "' | tee "/usr/lib/dracut/dracut.conf.d/30-bootcrew-bootc-container-build.conf"
dracut -v --force "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)/initramfs.img"

dnf config-manager setopt keepcache=0
