FROM base/archlinux:latest
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>, Alexander Kobel <alexander.kobel@mpi-inf.mpg.de>

# base/archlinux is really old; in particular, the packager keys are horribly outdated.
# We delete the original keyring and refresh it from scratch before the real setup:

# install the official Arch Linux keyring package
RUN pacman -Sy --noconfirm archlinux-keyring

# remove the old database of trusted keys the hard way and initialize a new database
# (Commented because it is currently unnecessary and takes a while;
# should only be used as a last resort if the base image is /really, really/ old.)
RUN rm -rf /etc/pacman.d/gnupg && \
    pacman-key --init

# add the keys from the offical keyring as trusted keys
RUN pacman-key --populate archlinux

# get updates to the trusted keys from the keyservers
RUN pacman-key --refresh-keys

# Now, we are good to update the base system.
RUN pacman -Su --noconfirm && \
    pacman-db-upgrade

# Update the database of trusted SSL certificates;
# otherwise, curl will fail later to download the AUR packages
RUN trust extract-compat

# We probably also need to update the list of mirrors;
# it's not automatically overwritten by the previous update through pacman.
# By default, all the servers are commented out; we uncomment the ones with French TLD.
RUN test -e /etc/pacman.d/mirrorlist.pacnew && \
    sed -e 's|^#\(.*Server.*\.fr/.*\)$|\1|' /etc/pacman.d/mirrorlist.pacnew > /etc/pacman.d/mirrorlist

# Finally, install additional packages beyond the baseline.
RUN pacman -S --noconfirm \
              base-devel boost cmake \
              eigen \
              glew glu mesa \
              gmp mpfr mpfi ntl \
              qt5-base qt5-script qt5-svg qt5-tools

# Install dependencies of the AUR (user repository) packages to be built from source later:
# ipe: freetype2, lua52, poppler, python2, zlib
# leda-free: tcsh
RUN pacman -S --noconfirm --asdeps \
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
