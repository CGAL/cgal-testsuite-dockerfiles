FROM debian:stable AS cgal-common

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
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
    qml6-module-qtcharts \
    qt6-declarative-dev \
    lsb-release \
    nlohmann-json3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN  git clone https://github.com/fastfloat/fast_float \
 &&  git -C /fast_float checkout v8.3.3 \
 &&  cmake -S /fast_float -B /fast_float/build \
 &&  cmake --build /fast_float/build --parallel "$(nproc)" \
 &&  cmake --install /fast_float/build \
 &&  rm -rf /fast_float


ENV CGAL_TEST_PLATFORM="Debian-Stable"
ENV CGAL_SUMMARY_NAME="Debian-stable-Debug"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt5=OFF \")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

FROM cgal-common AS cgal-base
ARG dockerfile_url
ARG image_tag
ENV DOCKERFILE_URL=$dockerfile_url
ENV IMAGE_TAG=$image_tag

FROM cgal-common AS cgal-toolbox
ARG dockerfile_url
ARG image_tag
ENV DOCKERFILE_URL=$dockerfile_url
ENV IMAGE_TAG=$image_tag

LABEL com.github.containers.toolbox="true" \
      name="cgal-toolbox" \
      usage="This image is meant to be used with the toolbox command"

COPY --from=root Debian-stable/toolbox-setup.sh /tmp/toolbox-setup.sh
RUN sh /tmp/toolbox-setup.sh && rm /tmp/toolbox-setup.sh
