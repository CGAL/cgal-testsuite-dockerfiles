FROM archlinux:base-devel
ARG dockerfile_url

# Install additional packages beyond the baseline.
# Install dependencies of the AUR (user repository) packages to be built from source later
#   ipe: freetype2, lua, poppler, python2, zlib
#   leda-free: tcsh
# and clean up the package cache
RUN pacman --noconfirm -Syu archlinux-keyring
RUN pacman -Syu --noconfirm && pacman -S --needed --noconfirm \
              base-devel \
              coreutils \
              git \
              boost \
              eigen \
              glew glu mesa \
              gmp mpfr mpfi ntl \
              qt5-base qt5-script qt5-svg qt5-tools \
	      intel-tbb \
    && pacman -S --needed --noconfirm --asdeps \
                 freetype2 lua poppler python2 zlib \
                 tcsh \
    && pacman -Scc
#Install latest cmake from the `next` branch on github
RUN git clone https://github.com/Kitware/CMake.git --depth 1 \
 && cd ./CMake \
 && git branch next \
 && mkdir build \
 && cd build \
 && env CC=cc CXX=c++ ../bootstrap \
 && make -j"$(nproc)" \
 && make install \
 && cd ../.. \
 && rm -rf ./CMake

# create a group for building AUR (user contributed) packages from sources
# (not allowed as root for security reasons)
RUN groupadd -r makepkg && \
    useradd -r -g makepkg makepkg && \
    mkdir /tmp/makepkg && \
    chown -R makepkg:makepkg /tmp/makepkg && \
    mkdir /home/makepkg && \
    chown -R makepkg:makepkg /home/makepkg

# get and build AUR packages
USER makepkg
WORKDIR /tmp/makepkg
RUN set -e; \
    for PKG in ipe esbtl leda-free librs; do \
        if curl -sSL https://aur.archlinux.org/cgit/aur.git/snapshot/${PKG}.tar.gz | tar xzv && \
           cd ${PKG} && makepkg --noconfirm; then \
               cd /tmp/makepkg; \
               mv ${PKG}/*.pkg.tar.zst .; \
               rm -rf ${PKG}; \
        fi; \
        cd /tmp/makepkg; \
    done

# install AUR packages and get rid of the build directories afterwards
USER root
WORKDIR /tmp/makepkg
RUN pacman -U --noconfirm *.pkg.tar.zst && \
    rm *.pkg.tar.zst

 RUN pacman -Sy --noconfirm unzip \
 && cd /tmp \
 && curl -sSL "https://github.com/CGAL/LAStools/archive/LAStools-2020-11-09.zip" -o master.zip \
 && unzip master.zip \
 && cd ./LAStools-LAStools-2020-11-09 \
 && cmake -DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/g++ -DCMAKE_CXX_FLAGS=-std=c++11 . \
 && make -j "$(nproc)" \
 && make install \
 && cd .. \
 && rm -rf LAStools-LAStools-2020-11-09 \
 && rm -rf master.zip \
 && pacman -Scc

# LEDA includes are in a nonstandard location (/usr/include/LEDA/LEDA/...
# instead of just /usr/include/LEDA/...) in Stephan Friedrich's AUR package,
# to avoid conflicts with other files.
#
# The CMAKE_GENERATOR trick is used to pass a CMake variable to each CMake
# run by the testsuite.
#
ENV CGAL_TEST_PLATFORM="ArchLinux" \
    CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\" \"-DCMAKE_POLICY_DEFAULT_CMP0053=OLD\")" \
    LEDA_INC_DIR=/usr/include/LEDA
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
