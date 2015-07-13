FROM debian:testing
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

RUN apt-get clean && apt-get update && apt-get install -y \
    build-essential \
    cmake \
    geomview \
    libboost-dev \
    libboost-program-options-dev \
    libboost-thread-dev \
    libeigen3-dev \
    libglew1.5-dev \
    libgmp10-dev \
    libipe-dev \
    libmpfi-dev \
    libmpfr-dev \
    libqglviewer-dev \
    libqt4-dev \
    libqt4-opengl-dev \
    qt4-dev-tools \
    qtbase5-dev \
    qtscript5-dev \
    qttools5-dev \
    libqt5svg5-dev \
    tar \
    zlib1g-dev

ENV CGAL_TEST_PLATFORM="Debian-Testing"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\")"
