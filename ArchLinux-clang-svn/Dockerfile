# This image can run the cgal-testsuite with the latest clang and libc++
FROM cgal/testsuite-docker:archlinux
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
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-Wall -Wextra -std=c++14 -stdlib=libc++\" \"-DWITH_CGAL_Qt3:BOOL=OFF\" \"-DCMAKE_POLICY_DEFAULT_CMP0053=OLD\" \"-DLEDA_INCLUDE_DIR=/usr/include/LEDA\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
