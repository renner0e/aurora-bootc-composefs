#!/bin/bash

set -ouex pipefail

dnf -y swap bootc https://kojipkgs.fedoraproject.org//packages/bootc/1.15.0/1.fc44/x86_64/bootc-1.15.0-1.fc44.x86_64.rpm
dnf -y install systemd-boot-unsigned

mkdir -p /usr/lib/dracut/dracut.conf.d/
printf "systemdsystemconfdir=/etc/systemd/system\nsystemdsystemunitdir=/usr/lib/systemd/system\n" | tee /usr/lib/dracut/dracut.conf.d/30-bootcrew-fix-bootc-module.conf
printf 'reproducible=yes\nhostonly=no\ncompress=zstd\nadd_dracutmodules+=" bootc "' | tee "/usr/lib/dracut/dracut.conf.d/30-bootcrew-bootc-container-build.conf"
dracut -v --force "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)/initramfs.img"

rm -rf /sysroot/ostree
