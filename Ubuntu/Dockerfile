FROM ubuntu:latest AS cgal-base
ARG dockerfile_url
ARG image_tag
ENV DOCKERFILE_URL=$dockerfile_url
ENV IMAGE_TAG=$image_tag
ENV CMAKE_POLICY_VERSION_MINIMUM=3.5

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential cmake \
    libopencv-dev \
    libsuitesparse-dev \
    tar \
    git \
    libboost-all-dev libgmp10-dev \
    libmpfr-dev zlib1g-dev \
    libeigen3-dev libipe-dev \
    libmpfi-dev \
    libtbb-dev git \
    nlohmann-json3-dev \
    lsb-release \
    libyaml-cpp-dev \
    libgl-dev \
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-svg-dev \
    qt6-websockets-dev \
    wget

#install vtk 9.3 to work around an issue in vtk 9.3.1
RUN wget https://www.vtk.org/files/release/9.3/VTK-9.3.1.tar.gz \
 && tar xf VTK-9.3.1.tar.gz \
 && cd VTK-9.3.1 \
 && sed -i 's/_M_chilren/m_children/g' /VTK-9.3.1/Utilities/octree/octree/octree_node.txx \
 && mkdir build \
 && cd build/ \
 && cmake -DCMAKE_BUILD_TYPE=Release .. \
 && make -j "$(nproc)" \
 && make install \
 && cd ../.. \
 && rm -rf VTK-9.3.1 \
 && rm  VTK-9.3.1.tar.gz

#manually install ITK compiled with our vtk version
RUN wget https://github.com/InsightSoftwareConsortium/ITK/releases/download/v5.3.0/InsightToolkit-5.3.0.tar.gz \
 && tar xf InsightToolkit-5.3.0.tar.gz \
 && cd InsightToolkit-5.3.0 \
 && mkdir build \
 && cd build/ \
 && export CFLAGS="-std=gnu17"; cmake -DCMAKE_BUILD_TYPE=Release .. \
 && sed -i '1 i\#include <stdint.h>' /InsightToolkit-5.3.0/Modules/Core/Common/include/itkFloatingPointExceptions.h \
 && sed -i '1 i\#include <stdint.h>' /InsightToolkit-5.3.0/Modules/Filtering/MathematicalMorphology/include/itkMathematicalMorphologyEnums.h \
 && make -j "$(nproc)" VERBOSE=1\
 && make install \
 && cd ../.. \
 && rm InsightToolkit-5.3.0 -r \
 && rm InsightToolkit-5.3.0.tar.gz

RUN git clone https://github.com/STORM-IRIT/OpenGR.git --depth 1 \
 && cd ./OpenGR \
 && mkdir build \
 && cd build \
 && cmake .. \
 && make -j"$(nproc)" \
 && make install \
 && mkdir -p /usr/local/lib/cmake/opengr \
 && cd ../.. \
 && rm -rf ./OpenGR

RUN git clone https://github.com/ethz-asl/libnabo.git --depth 1 \
 && cd libnabo \
 && SRC_DIR=`pwd` && BUILD_DIR=${SRC_DIR}/build \
 && mkdir -p ${BUILD_DIR} && cd ${BUILD_DIR} \
 && cmake -DCMAKE_BUILD_TYPE=Release -DUSE_OPEN_MP=False ${SRC_DIR} \
 && make && make install \
 && cd ../.. && rm -rf libnado

RUN git clone https://github.com/ethz-asl/libpointmatcher.git \
 && cd libpointmatcher \
 && git switch -d 3eb448330b \
 && sed -i 's/Boost_USE_STATIC_LIBS  ON/Boost_USE_STATIC_LIBS  OFF/' CMakeLists.txt \
 && sed -i 's/thread system/thread/' libpointmatcherConfig.cmake.in CMakeLists.txt\
 && SRC_DIR=`pwd` \
 && BUILD_DIR=${SRC_DIR}/build \
 && mkdir -p ${BUILD_DIR} && cd ${BUILD_DIR} \
 && cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=OFF -DBUILD_EVALUATIONS=OFF ${SRC_DIR} \
 && make -j"$(nproc)" && make install \
 && cd ../.. && rm -rf libpointmatcher
 # Commit 3eb448330b is 1.4.4

RUN git clone --recursive https://github.com/oxfordcontrol/osqp  --depth 1 \
 && cd ./osqp \
 && mkdir build \
 && cd build \
 && cmake .. \
 && make -j"$(nproc)" \
 && make install \
 && cd ../.. \
 && rm -rf osqp

RUN git clone https://github.com/scipopt/soplex --depth 1 \
 && cd soplex \
 && mkdir build \
 && cd build \
 && cmake .. \
 && make -j"$(nproc)" \
 && make install \
 && cd .. \
 && rm -rf soplex

RUN git clone https://github.com/scipopt/scip --depth 1 \
 && cd scip \
 && mkdir build \
 && cd build \
 && cmake -DAUTOBUILD=ON .. \
 && make -j"$(nproc)" \
 && make install \
 && cd .. \
 && rm -rf scip

RUN git clone https://ceres-solver.googlesource.com/ceres-solver \
 && cd ceres-solver \
 && git checkout 2.2.0 \
 && mkdir build \
 && cd build \
 && cmake -DMINIGLOG=ON -DMINIGLOG_MAX_LOG_LEVEL=0 .. \
 && make -j"$(nproc)" \
 && make install \
 && cd .. \
 && rm -rf ceres-solver

RUN  git clone https://github.com/fastfloat/fast_float \
 &&  cd fast_float \
 &&  git checkout v8.3.3 \
 &&  mkdir build \
 &&  cd build \
 &&  cmake .. \
 &&  make install \
 && cd .. && rm -rf fast_float

ENV CGAL_TEST_PLATFORM="Ubuntu-Latest"
ENV CGAL_SUMMARY_NAME="Ubuntu-latest-Debug"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt5:BOOL=OFF\")"
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

# Remove the base image's UID 1000 user so Toolbx can create the host user.
RUN if getent group ubuntu >/dev/null; then userdel --remove ubuntu; fi && if getent group ubuntu >/dev/null; then groupdel ubuntu; fi

# Configure hostname resolution for toolbox compatibility
RUN grep -Eq '^hosts:.*[[:space:]]myhostname([[:space:]]|$)' /etc/nsswitch.conf || sed -Ei 's/^(hosts:.*\<files\>)/\1 myhostname/' /etc/nsswitch.conf

# Install libnss-myhostname for proper hostname resolution
RUN apt-get update && apt-get install -y libnss-myhostname && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create required directories for toolbox
RUN mkdir -p /usr/share/empty /etc/pkcs11/modules /etc/krb5.conf.d

# Install sudo and zsh for toolbox environment
RUN apt-get update && apt-get install -y sudo zsh flatpak-xdg-utils p11-kit-modules libvte-2.91-common && ln -sf /usr/libexec/flatpak-xdg-utils/flatpak-spawn /usr/bin/flatpak-spawn && { [ -e /etc/profile.d/vte.sh ] || ln -s "$(ls /etc/profile.d/vte-*.sh | head -1)" /etc/profile.d/vte.sh; } && apt-get clean && rm -rf /var/lib/apt/lists/*

# Allow the Toolbx user to use sudo without a password
RUN printf '%s\n' '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-toolbox && chmod 0440 /etc/sudoers.d/99-toolbox
