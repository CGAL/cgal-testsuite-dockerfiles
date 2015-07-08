FROM base/archlinux:latest
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

# base/archlinux is really old and we need to perform some manual
# magic when updating
RUN pacman -Sy --noconfirm && \
    pacman-key --refresh-keys && \
    pacman -Su --noconfirm && \
    pacman-db-upgrade
RUN pacman -S --noconfirm \
              base-devel \
              boost \
              cmake \
              eigen \
              glew \
              glu \
              gmp \
              mesa \
              mpfi \
              mpfr \
              qt4 \
              qt5-base \
              qt5-script \
              qt5-svg \
              zlib
RUN pacman -Scc --noconfirm # clean up

RUN groupadd -r makepkg
RUN useradd -r -g makepkg makepkg
RUN mkdir /tmp/makepkg
RUN chown -R makepkg:makepkg /tmp/makepkg

USER makepkg
WORKDIR /tmp/makepkg
RUN curl -SL https://aur.archlinux.org/packages/li/libqglviewer-qt4/libqglviewer-qt4.tar.gz | tar xzv && \
    sed -i -e 's/2fa216dff83a352bf4bc0ef40b341036/65d41b1fa3e1e5396cb2952b8c032c6c/' libqglviewer-qt4/PKGBUILD && \
    cd libqglviewer-qt4 && makepkg --noconfirm

USER root
RUN pacman -U --noconfirm libqglviewer-qt4/*.pkg.tar.xz && rm -rf libqglviewer-qt4

ENV CGAL_TEST_PLATFORM="ArchLinux"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\")"
