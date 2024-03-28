FROM debian:stable
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN apt-get update && apt-get install -y \
    build-essential \
    libmetis-dev \
    geomview \
    libboost-dev \
    libboost-program-options-dev \
    libboost-thread-dev \
    libeigen3-dev \
    libgmp10-dev \
    libipe-dev \
    libmpfi-dev \
    libmpfr-dev \
    tar \
    zlib1g-dev \
    libtbb-dev \
    cmake \
    curl \
    git \
    libqt6qmlworkerscript6 \
    qt6-svg-dev \
    qt6-base-dev \
    libqt6opengl6-dev \
    libqt6openglwidgets6 \
    libqt6qml6 \
    qt6-websockets-dev \
    qt6-networkauth-dev \
    libqt6chartsqml6 \
    qt6-declarative-dev \
    nlohmann-json3-dev


ENV CGAL_TEST_PLATFORM="Debian-Stable"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt5=OFF \")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
