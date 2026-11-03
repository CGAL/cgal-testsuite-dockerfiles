FROM debian:stable as cgal-base
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url
ARG image_tag
ENV IMAGE_TAG=$image_tag

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
    qml6-module-qtcharts \
    qt6-declarative-dev \
    lsb-release \
    nlohmann-json3-dev

RUN  git clone https://github.com/fastfloat/fast_float \
 &&  cd fast_float \
 &&  git checkout v8.3.3 \
 &&  mkdir build \
 &&  cd build \
 &&  cmake .. \
 &&  make install \
 && cd .. && rm -rf fast_float


ENV CGAL_TEST_PLATFORM="Debian-Stable"
ENV CGAL_SUMMARY_NAME="Debian-stable-Debug"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt5=OFF \")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

# ===== STAGE 2: Toolbox Variant =====
# Derived from cgal-base with toolbox-specific configurations
FROM cgal-base as cgal-toolbox

LABEL com.github.containers.toolbox="true" \
      name="cgal-toolbox" \
      usage="This image is meant to be used with the toolbox command"

# Remove container-specific optimizations that conflict with toolbox
RUN rm -f /etc/apt/apt.conf.d/docker-*

# Configure hostname resolution for toolbox compatibility
RUN grep -Eq '^hosts:.*[[:space:]]myhostname([[:space:]]|$)' /etc/nsswitch.conf || sed -Ei 's/^(hosts:.*\<files\>)/\1 myhostname/' /etc/nsswitch.conf

# Install libnss-myhostname for proper hostname resolution
RUN apt-get update && apt-get install -y libnss-myhostname && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create required directories for toolbox
RUN mkdir -p /usr/share/empty /etc/pkcs11/modules /etc/krb5.conf.d

# Install sudo and zsh for toolbox environment
RUN apt-get update && apt-get install -y sudo zsh && apt-get clean && rm -rf /var/lib/apt/lists/*

# Allow the Toolbx user to use sudo without a password
RUN printf '%s\n' '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-toolbox && chmod 0440 /etc/sudoers.d/99-toolbox
