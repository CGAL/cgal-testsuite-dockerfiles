#!/bin/sh
set -e

rm -f /etc/apt/apt.conf.d/docker-*
grep -Eq '^hosts:.*[[:space:]]myhostname([[:space:]]|$)' /etc/nsswitch.conf || sed -Ei 's/^(hosts:.*\<files\>)/\1 myhostname/' /etc/nsswitch.conf
apt-get update
apt-get install -y libnss-myhostname
apt-get clean
rm -rf /var/lib/apt/lists/*
mkdir -p /usr/share/empty /etc/pkcs11/modules /etc/krb5.conf.d
apt-get update
apt-get install -y sudo zsh flatpak-xdg-utils p11-kit-modules libvte-2.91-common "$@"
ln -sf /usr/libexec/flatpak-xdg-utils/flatpak-spawn /usr/bin/flatpak-spawn
# shellcheck disable=SC2012
[ -e /etc/profile.d/vte.sh ] || ln -s "$(ls /etc/profile.d/vte-*.sh | head -1)" /etc/profile.d/vte.sh
apt-get clean
rm -rf /var/lib/apt/lists/*
printf '%s\n' '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-toolbox
chmod 0440 /etc/sudoers.d/99-toolbox
