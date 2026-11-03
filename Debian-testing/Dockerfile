FROM debian:testing AS cgal-base
ARG dockerfile_url
ARG image_tag
ENV DOCKERFILE_URL=$dockerfile_url
ENV IMAGE_TAG=$image_tag

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
    git \
    libtbb-dev \
    zlib1g-dev \
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
    libvtk9-dev vtk9 \
    nlohmann-json3-dev \
    wget

#OpenMesh
# https://www.graphics.rwth-aachen.de/media/openmesh_static/Releases/11.0/OpenMesh-11.0.0.tar.gz
RUN  wget https://src.fedoraproject.org/repo/pkgs/rpms/OpenMesh/OpenMesh-11.0.0.tar.bz2/sha512/4667ef9ae935403455a57277bd81dd61eb967f81dcbcc8ce5a84d537d60db37b0155dc7c118b14f90e142e44b0a453fd98984de17e20fae62c86be2ddc6e9a69/OpenMesh-11.0.0.tar.bz2 && \
     tar xf OpenMesh-11.0.0.tar.bz2 && \
     cd OpenMesh-11.0.0/ && \
     mkdir build && \
     cd build && \
     cmake -DCMAKE_BUILD_TYPE=Release .. && \
     make && make install && \
     cd ../.. && rm -r OpenMesh-11.0.0*

RUN  git clone https://github.com/fastfloat/fast_float \
 &&  cd fast_float \
 &&  git checkout v8.3.3 \
 &&  mkdir build \
 &&  cd build \
 &&  cmake .. \
 &&  make install \
 && cd .. && rm -rf fast_float

ENV OpenMesh_DIR=/OpenMesh-11.0.0/build



ENV CGAL_TEST_PLATFORM="Debian-Testing"
ENV CGAL_SUMMARY_NAME="Debian-testing-Debug"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

# ===== STAGE 2: Toolbox Variant =====
# Derived from cgal-base with toolbox-specific configurations
FROM cgal-base AS cgal-toolbox

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
RUN apt-get update && apt-get install -y sudo zsh libcap2-bin && apt-get clean && rm -rf /var/lib/apt/lists/*

# Allow the Toolbx user to use sudo without a password
RUN printf '%s\n' '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-toolbox && chmod 0440 /etc/sudoers.d/99-toolbox
