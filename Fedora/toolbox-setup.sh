#!/bin/sh
set -e

rm -f /etc/containers/mounts.conf /etc/containers/containers.conf /etc/containers/registries.conf /etc/containers/storage.conf
grep -Eq '^hosts:.*[[:space:]]myhostname([[:space:]]|$)' /etc/nsswitch.conf || sed -Ei 's/^(hosts:.*\<files\>)/\1 myhostname/' /etc/nsswitch.conf
mkdir -p /usr/share/empty /etc/pkcs11/modules /etc/krb5.conf.d
dnf install -y sudo zsh flatpak-xdg-utils p11-kit-client vte-profile
dnf clean all
printf '%s\n' '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-toolbox
chmod 0440 /etc/sudoers.d/99-toolbox
