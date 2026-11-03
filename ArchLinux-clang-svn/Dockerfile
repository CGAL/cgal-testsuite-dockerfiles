# This image can run the cgal-testsuite with the latest clang and libc++
FROM cgal/testsuite-docker:archlinux as cgal-base
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

# Tools needed to build llvm
RUN pacman -Syyu --noconfirm
RUN pacman -S --noconfirm --needed --asdeps \
              chrpath \
              ocaml-ctypes \
              ocaml-findlib \
              python2-sphinx \
              python2 \
              subversion

# clean up the package cache
RUN yes | pacman -Scc

USER makepkg
WORKDIR /tmp/makepkg

RUN curl -s -SL https://aur.archlinux.org/cgit/aur.git/snapshot/llvm-svn.tar.gz | tar xzv && \
    cd llvm-svn && makepkg --noconfirm

# Outdated: The libc++-svn package has not been ported to AUR4;
# the llvm-libs are now provided as a sub-package of llvm-svn
# RUN curl -s -SL https://aur.archlinux.org/packages/li/libc++-svn/libc++-svn.tar.gz | tar xzv && \
#     cd libc++-svn && makepkg --noconfirm

USER root

# remove llvm-libs without dependency checks to prepare replacement
# (pulled in as dependency of libqglviewer -> mesa)...
RUN pacman --noconfirm -Rdd llvm-libs
# ... and install the llvm-svn packages
RUN pacman --noconfirm -U llvm-svn/*.pkg.tar.zst && rm -rf llvm-svn

# see above: not necessary anymore
# RUN pacman --noconfirm -U libc++-svn/*.pkg.tar.zst && rm -rf libc++-svn

ENV CC=clang
ENV CXX=clang++
ENV CGAL_TEST_PLATFORM="ArchLinux-clang-svn"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-Wall -Wextra -std=c++14 -stdlib=libc++\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

# ===== STAGE 2: Toolbox Variant =====
# Derived from cgal-base with toolbox-specific configurations
FROM cgal-base as cgal-toolbox

LABEL com.github.containers.toolbox="true" \
      name="cgal-toolbox" \
      usage="This image is meant to be used with the toolbox command"

# Configure hostname resolution for toolbox compatibility
RUN grep -Eq '^hosts:.*[[:space:]]myhostname([[:space:]]|$)' /etc/nsswitch.conf || sed -Ei 's/^(hosts:.*\<files\>)/\1 myhostname/' /etc/nsswitch.conf

# Create required directories for toolbox
RUN mkdir -p /usr/share/empty /etc/pkcs11/modules /etc/krb5.conf.d

# Install toolbox tools and enable passwordless sudo for the wheel group
RUN pacman -Syu --noconfirm sudo zsh systemd-libs libcap shadow && \
    printf '%s\n' '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-toolbox && \
    chmod 0440 /etc/sudoers.d/99-toolbox && \
    pacman -Scc --noconfirm && \
    rm -rf /home/makepkg
