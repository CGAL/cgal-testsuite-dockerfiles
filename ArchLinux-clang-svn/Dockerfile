# This image can run the cgal-testsuite with the latest clang and libc++
FROM cgal/testsuite-docker:archlinux
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

# Tools needed to build llvm
RUN pacman -S wget subversion python2 \
              ocaml-ctypes ocaml-findlib \
              python-sphinx chrpath --noconfirm

RUN groupadd -r makepkg
RUN useradd -r -g makepkg makepkg
RUN mkdir /tmp/makepkg
RUN chown -R makepkg:makepkg /tmp/makepkg

USER makepkg
WORKDIR /tmp/makepkg

RUN wget https://aur.archlinux.org/packages/ll/llvm-svn/llvm-svn.tar.gz && tar xvf llvm-svn.tar.gz
RUN cd llvm-svn && makepkg --noconfirm
ENV CC=clang
ENV CXX=clang++

RUN wget https://aur.archlinux.org/packages/li/libc++-svn/libc++-svn.tar.gz && tar xvf libc++-svn.tar.gz
RUN cd libc++-svn && makepkg --noconfirm

USER root

WORKDIR /tmp/makepkg/llvm-svn
RUN pacman --noconfirm -U *.tar.xz
WORKDIR /tmp/makepkg/libc++-svn
RUN pacman --noconfirm -U *.tar.xz

ENV CGAL_TEST_PLATFORM="ArchLinux-clang-svn"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-Wall -Wextra -std=c++14 -stdlib=libc++\" \"-DWITH_CGAL_Qt3:BOOL=OFF\")"
