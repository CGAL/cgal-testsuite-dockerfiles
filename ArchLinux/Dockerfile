FROM base/archlinux:latest
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

# base/archlinux is really old and we need to perform some manual
# magic when updating
RUN pacman -Sy --noconfirm && \
    pacman-key --refresh-keys && \
    pacman -Su --noconfirm && \
    pacman-db-upgrade
# lua, poppler, and python2 are depdendencies of ipe
RUN pacman -S --noconfirm \
              base-devel \
              boost \
              cmake \
              eigen \
              glew \
              glu \
              gmp \
              lua \
              mesa \
              mpfi \
              mpfr \
              poppler \
              python2 \
              qt4 \
              qt5-base \
              qt5-script \
              qt5-svg \
              qt5-tools \
              zlib && \
    yes|pacman -Scc # clean up

RUN groupadd -r makepkg && \
    useradd -r -g makepkg makepkg && \
    mkdir /tmp/makepkg && \
    chown -R makepkg:makepkg /tmp/makepkg && \
    mkdir /home/makepkg && \
    chown -R makepkg:makepkg /home/makepkg

USER makepkg
WORKDIR /tmp/makepkg
RUN curl -SL https://aur.archlinux.org/packages/li/libqglviewer-qt4/libqglviewer-qt4.tar.gz | tar xzv && \
    sed -i -e 's/2fa216dff83a352bf4bc0ef40b341036/65d41b1fa3e1e5396cb2952b8c032c6c/' libqglviewer-qt4/PKGBUILD && \
    cd libqglviewer-qt4 && makepkg --noconfirm

RUN curl -SL https://aur.archlinux.org/packages/ip/ipe/ipe.tar.gz | tar xzv && \
    cd ipe && makepkg --noconfirm

RUN curl -SL https://aur.archlinux.org/packages/ip/ipe/ipe.tar.gz | tar xzv && \
    cd ipe && makepkg --noconfirm
    
RUN curl -SL https://aur.archlinux.org/packages/es/esbtl/esbtl.tar.gz | tar xzv && \
    cd esbtl && makepkg --noconfirm

USER root
RUN pacman -U --noconfirm libqglviewer-qt4/*.pkg.tar.xz ipe/*.pkg.tar.xz esbtl/*.pkg.tar.xz && \
    rm -rf libqglviewer-qt4 ipe esbtl

ENV CGAL_TEST_PLATFORM="ArchLinux"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\")"
