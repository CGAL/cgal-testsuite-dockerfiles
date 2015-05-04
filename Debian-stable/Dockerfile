FROM debian:stable

RUN apt-get update && apt-get install -y \
    build-essential cmake \
    libboost-dev libboost-program-options-dev \
    libboost-thread-dev libgmp10-dev \
    libmpfr-dev libqt4-dev zlib1g-dev \
    geomview libeigen3-dev libglew1.5-dev libipe-dev \
    libmpfi-dev libqglviewer-qt4-dev libqt4-opengl-dev qt4-dev-tools 

ENV CGAL_TEST_PLATFORM="Debian-Stable"
ENV CGAL_CMAKE_FLAGS=""