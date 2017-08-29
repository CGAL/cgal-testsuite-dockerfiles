FROM fedora:latest
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

RUN dnf -y update; dnf clean all
RUN dnf -y install \
    boost-devel.x86_64 \
    cmake \
    eigen3-devel.noarch \
    gcc-c++ \
    glew-devel.x86_64 \
    gmp-devel.x86_64 \
    ipe-devel.x86_64 \
    OpenMesh-devel \
    opencv-devel \
    libQGLViewer-qt5-devel.x86_64 \
    make \
    mpfr-devel.x86_64 \
    mpfi-devel.x86_64 \
    ntl-devel.x86_64 \
    qt5-qtbase-devel.x86_64 \
    qt5-qtscript-devel.x86_64 \
    qt5-qtsvg-devel.x86_64 \
    qt5-qttools-devel.x86_64 \
    tar \
    unzip \
    wget \
    zlib-devel.x86_64

RUN wget "https://github.com/CGAL/LAStools/archive/master.zip" -O laslib.zip \
 && unzip laslib.zip \
 && cd ./LAStools-master \
 && cmake -DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/g++ -DCMAKE_CXX_FLAGS=-std=c++11 . \
 && make -j "$(nproc)" \
 && make install \
 && cd .. \
 && rm -rf LAStools-master \
 && rm -rf laslib.zip


ENV CGAL_TEST_PLATFORM="Fedora"
ENV CGAL_CMAKE_FLAGS=""
