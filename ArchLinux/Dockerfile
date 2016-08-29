FROM base/archlinux:latest
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

# base/archlinux is really old and we need to perform some manual
# magic when updating
RUN pacman -Sy --noconfirm && \
    pacman-key --refresh-keys && \
    pacman -Su --noconfirm && \
    pacman-db-upgrade

# freetype2, lua52, poppler, python2, zlib are depdendencies of ipe
RUN pacman -S --noconfirm \
              base-devel \
              boost \
              cmake \
              eigen \
              freetype2 \
              glew \
              glu \
              gmp \
              lua52 \
              mesa \
              mpfi \
              mpfr \
              ntl \
              poppler \
              python2 \
              libqglviewer \
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
             
RUN curl -s -SL https://aur.archlinux.org/cgit/aur.git/snapshot/ipe.tar.gz | tar xzv && \
    cd ipe && makepkg --noconfirm
    
RUN curl -s -SL https://aur.archlinux.org/cgit/aur.git/snapshot/esbtl.tar.gz | tar xzv && \
    cd esbtl && makepkg --noconfirm

RUN curl -s -SL https://aur.archlinux.org/cgit/aur.git/snapshot/leda-free.tar.gz | tar xzv && \
    cd leda-free && makepkg --noconfirm

RUN curl -s -SL https://aur.archlinux.org/cgit/aur.git/snapshot/librs.tar.gz | tar xzv && \
    cd librs && makepkg --noconfirm

USER root
RUN pacman -U --noconfirm ipe/*.pkg.tar.xz esbtl/*.pkg.tar.xz leda-free/*.pkg.tar.xz librs/*.pkg.tar.xz && \
    rm -rf ipe esbtl leda-free librs

ENV CGAL_TEST_PLATFORM="ArchLinux"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\")"
