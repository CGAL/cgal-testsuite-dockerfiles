FROM debian:stable
ARG dockerfile_url

RUN apt-get update && apt-get install -y \
    build-essential \
    libmetis-dev \
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
    tar \
    zlib1g-dev \
    libtbb-dev \
    cmake \
    curl

ENV CGAL_TEST_PLATFORM="Debian-Stable"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF -DWITH_CGAL_Qt5=OFF \")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
