FROM debian:stable
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

RUN apt-get clean && apt-get update && apt-get install -y \
    build-essential \
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
    libqglviewer-dev-qt5 \
    qtbase5-dev \
    qtscript5-dev \
    libqt5svg5-dev \
    libqt5opengl5-dev \
    qttools5-dev \
    qttools5-dev-tools \
    tar \
    zlib1g-dev \
    curl

RUN curl -fSL "https://cmake.org/files/v3.1/cmake-3.1.3-Linux-x86_64.sh" -o /usr/cmake.sh
RUN cd /usr \
 && chmod +x ./cmake.sh

RUN cd /usr \
&& ./cmake.sh --skip-license

ENV CGAL_TEST_PLATFORM="Debian-Stable"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\")"
