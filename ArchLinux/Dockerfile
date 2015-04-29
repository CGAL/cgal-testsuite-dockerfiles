FROM base/archlinux:latest
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

# base/archlinux is really old and we need to perform some manual
# magic when updating
RUN pacman -Sy --noconfirm
RUN pacman-key --refresh-keys
RUN pacman -Su --noconfirm
RUN pacman-db-upgrade
RUN pacman -S base-devel cmake qt4 gmp mpfi mpfr boost zlib mesa glu eigen --noconfirm
RUN pacman -Scc --noconfirm # clean up

ENV CGAL_TEST_PLATFORM="ArchLinux"