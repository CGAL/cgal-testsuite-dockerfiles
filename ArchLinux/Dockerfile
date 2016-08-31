FROM base/archlinux:latest
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>, Alexander Kobel <alexander.kobel@mpi-inf.mpg.de>

# base/archlinux is /ancient/; in particular, the packager keys are horribly outdated.
# We need to repopulate the keyring from scratch before the real setup:

# install the official Arch Linux keyring package
RUN pacman -Sy --noconfirm archlinux-keyring

# This is a "soft" version that deletes all packager keys, but preserves the local master key.
#   pacman-key --list-keys | grep -B1 '\[ultimate\]' | head -n1 | cut -d/ -f2 | cut -d' ' -f1
# determines the fingerprint of the local "Pacman Keyring Master Key" (unique one with ultimate trust);
# we delete every key except this one.
RUN pacman-key --delete \
    $(pacman-key --list-keys \
      | grep '^pub' | cut -d/ -f2 | cut -d' ' -f1 \
      | grep -v $(pacman-key --list-keys | grep -B1 '\[ultimate\]' | head -n1 | cut -d/ -f2 | cut -d' ' -f1))

# # Here is the equivalent call for more recent pacman-key syntax (once the base image gets updated):
# #   pacman-key --list-keys | grep -B1 '\[ultimate\]' | head -n1
# # determines the fingerprint of the local "Pacman Keyring Master Key" (unique one with ultimate trust);
# # we delete every key except this one.
# RUN pacman-key --delete \
#     $(pacman-key --list-keys \
#       | grep '^  ' \
#       | grep -v $(pacman-key --list-keys | grep -B1 '\[ultimate\]' | head -n1))

# # Finally, here is a way to clear the old database of trusted keys the HARD way and initialize a new database.
# # This should hopefully be unnecessary except in the darkest hours; but nobody knows the trouble I've seen...
# # Regenerating a new private key requires a lot of randomness and is not suited for a virtual machine where randomness is scarce.
# # Only use it as a last resort if nothing else works.
# RUN rm -rf /etc/pacman.d/gnupg && \
#     pacman-key --init

# add the keys from the offical keyring as trusted keys
RUN pacman-key --populate archlinux

# get updates to the trusted keys from the keyservers
RUN pacman-key --refresh-keys

# Now, we are good to update the base system.
RUN pacman -Syyu --noconfirm && \
    pacman-db-upgrade

# Update the database of trusted SSL certificates;
# otherwise, curl will fail later to download the AUR packages
RUN trust extract-compat

# We probably also need to update the list of mirrors;
# it's not automatically overwritten by the previous update through pacman.
# By default, all the servers are commented out; we uncomment the ones with French TLD.
RUN test -e /etc/pacman.d/mirrorlist.pacnew && \
    sed -e 's|^#\(.*Server.*\.fr/.*\)$|\1|' /etc/pacman.d/mirrorlist.pacnew > /etc/pacman.d/mirrorlist

# Install and run reflector to get determine reasonably fast and up-to-date mirrors
RUN pacman -S --noconfirm reflector && \
    reflector --verbose \
              --country France --country Germany \
              --protocol http --protocol https --protocol ftp \
              --latest 32 --sort rate --number 16 \
              --save /etc/pacman.d/mirrorlist

# Finally, install additional packages beyond the baseline.
RUN pacman -S --needed --noconfirm \
              base-devel boost cmake \
              eigen \
              glew glu mesa \
              gmp mpfr mpfi ntl \
              qt5-base qt5-script qt5-svg qt5-tools

# Install dependencies of the AUR (user repository) packages to be built from source later:
# ipe: freetype2, lua52, poppler, python2, zlib
# leda-free: tcsh
RUN pacman -S --needed --noconfirm --asdeps \
    freetype2 lua52 poppler python2 zlib \
    tcsh

# clean up the package cache
RUN yes | pacman -Scc

# create a group for building AUR (user contributed) packages from sources
# (not allowed as root for security reasons)
RUN groupadd -r makepkg && \
    useradd -r -g makepkg makepkg && \
    mkdir /tmp/makepkg && \
    chown -R makepkg:makepkg /tmp/makepkg && \
    mkdir /home/makepkg && \
    chown -R makepkg:makepkg /home/makepkg

USER makepkg
WORKDIR /tmp/makepkg

# get and build AUR packages
RUN for PKG in ipe libqglviewer esbtl leda-free librs; do \
        curl -sSL https://aur.archlinux.org/cgit/aur.git/snapshot/${PKG}.tar.gz | tar xzv && \
        pushd ${PKG} && makepkg --noconfirm && popd; \
    done

# install AUR packages and get rid of the build directories afterwards
USER root
RUN for PKG in ipe libqglviewer esbtl leda-free librs; do \
        pacman -U --noconfirm ${PKG}/*.pkg.tar.xz && \
        rm -rf ${PKG}; \
    done

ENV CGAL_TEST_PLATFORM="ArchLinux"

# LEDA includes are in a nonstandard location (/usr/include/LEDA/LEDA/...
# instead of just /usr/include/LEDA/...) in Stephan Friedrich's AUR package,
# to avoid conflicts with other files.
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\" \"-DLEDA_INCLUDE_DIR=/usr/include/LEDA\")"
