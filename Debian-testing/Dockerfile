FROM debian:testing AS cgal-common

RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends \
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
    wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

#OpenMesh
# https://www.graphics.rwth-aachen.de/media/openmesh_static/Releases/11.0/OpenMesh-11.0.0.tar.gz
RUN  wget --progress=dot:giga https://src.fedoraproject.org/repo/pkgs/rpms/OpenMesh/OpenMesh-11.0.0.tar.bz2/sha512/4667ef9ae935403455a57277bd81dd61eb967f81dcbcc8ce5a84d537d60db37b0155dc7c118b14f90e142e44b0a453fd98984de17e20fae62c86be2ddc6e9a69/OpenMesh-11.0.0.tar.bz2 && \
     printf '%s  %s\n' '4667ef9ae935403455a57277bd81dd61eb967f81dcbcc8ce5a84d537d60db37b0155dc7c118b14f90e142e44b0a453fd98984de17e20fae62c86be2ddc6e9a69' 'OpenMesh-11.0.0.tar.bz2' > /tmp/OpenMesh-11.0.0.sha512 && \
     sha512sum -c /tmp/OpenMesh-11.0.0.sha512 && \
     rm /tmp/OpenMesh-11.0.0.sha512 && \
     tar xf OpenMesh-11.0.0.tar.bz2 && \
     cmake -S /OpenMesh-11.0.0 -B /OpenMesh-11.0.0/build -DCMAKE_BUILD_TYPE=Release && \
     cmake --build /OpenMesh-11.0.0/build --parallel "$(nproc)" && \
     cmake --install /OpenMesh-11.0.0/build && \
     rm -r /OpenMesh-11.0.0*

RUN  git clone https://github.com/fastfloat/fast_float \
 &&  git -C /fast_float checkout v8.3.3 \
 &&  cmake -S /fast_float -B /fast_float/build \
 &&  cmake --build /fast_float/build --parallel "$(nproc)" \
 &&  cmake --install /fast_float/build \
 &&  rm -rf /fast_float

ENV CGAL_TEST_PLATFORM="Debian-Testing"
ENV CGAL_SUMMARY_NAME="Debian-testing-Debug"
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
RUN sh /tmp/toolbox-setup.sh libcap2-bin && rm /tmp/toolbox-setup.sh
