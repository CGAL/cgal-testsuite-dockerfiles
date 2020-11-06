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
    libmpfi-dev \
    libmpfr-dev \
    libqglviewer-dev-qt5 \
    qtbase5-dev \
    qtscript5-dev \
    qttools5-dev \
    qttools5-dev-tools \
    libqt5svg5-dev \
    libqt5opengl5-dev \
    tar \
    libtbb-dev \
    zlib1g-dev

ENV CGAL_TEST_PLATFORM="Debian-Testing"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
