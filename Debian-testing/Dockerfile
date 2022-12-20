FROM debian:testing
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN apt-get clean && apt-get update && apt-get install -y \
    build-essential \
    cmake \
    geomview \
    libboost-dev \
    libboost-program-options-dev \
    libboost-thread-dev \
    libeigen3-dev \
    libglew-dev \
    libgmp10-dev \
    libipe-dev \
    libmpfi-dev \
    libmpfr-dev \
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
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
