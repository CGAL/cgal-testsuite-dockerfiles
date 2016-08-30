# This image can run the cgal-testsuite with the latest clang and libc++
FROM cgal/testsuite-docker:archlinux
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

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

# The libc++-svn package has not been ported to AUR4.
# RUN curl -s -SL https://aur.archlinux.org/packages/li/libc++-svn/libc++-svn.tar.gz | tar xzv && \
#     cd libc++-svn && makepkg --noconfirm

USER root
RUN pacman --noconfirm -U llvm-svn/*.pkg.tar.xz libc++-svn/*.pkg.tar.xz && rm -rf llvm-svn libc++-svn

ENV CC=clang
ENV CXX=clang++
ENV CGAL_TEST_PLATFORM="ArchLinux-clang-svn"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-Wall -Wextra -std=c++14 -stdlib=libc++\" \"-DWITH_CGAL_Qt3:BOOL=OFF\" \"-DLEDA_INCLUDE_DIR=/usr/include/LEDA\")"
