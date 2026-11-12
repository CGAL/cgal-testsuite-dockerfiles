#!/bin/sh
set -e

grep -Eq '^hosts:.*[[:space:]]myhostname([[:space:]]|$)' /etc/nsswitch.conf || sed -Ei 's/^(hosts:.*\<files\>)/\1 myhostname/' /etc/nsswitch.conf
mkdir -p /usr/share/empty /etc/pkcs11/modules /etc/krb5.conf.d
pacman -Syu --noconfirm sudo zsh systemd-libs libcap shadow flatpak-xdg-utils p11-kit vte-common
printf '%s\n' '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-toolbox
chmod 0440 /etc/sudoers.d/99-toolbox
pacman -Scc --noconfirm
rm -rf /home/makepkg
