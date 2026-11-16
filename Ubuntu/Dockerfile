FROM ubuntu:latest AS cgal-common
ENV CMAKE_POLICY_VERSION_MINIMUM=3.5

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential cmake \
    ca-certificates \
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
    wget \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

#install vtk 9.3 to work around an issue in vtk 9.3.1
RUN wget --progress=dot:giga https://www.vtk.org/files/release/9.3/VTK-9.3.1.tar.gz \
 && tar xf VTK-9.3.1.tar.gz \
 && sed -i 's/_M_chilren/m_children/g' /VTK-9.3.1/Utilities/octree/octree/octree_node.txx \
 && cmake -S /VTK-9.3.1 -B /VTK-9.3.1/build -DCMAKE_BUILD_TYPE=Release \
 && cmake --build /VTK-9.3.1/build --parallel "$(nproc)" \
 && cmake --install /VTK-9.3.1/build \
 && rm -rf /VTK-9.3.1 /VTK-9.3.1.tar.gz

#manually install ITK compiled with our vtk version
RUN wget --progress=dot:giga https://github.com/InsightSoftwareConsortium/ITK/releases/download/v5.3.0/InsightToolkit-5.3.0.tar.gz \
 && tar xf InsightToolkit-5.3.0.tar.gz \
 && export CFLAGS="-std=gnu17" \
 && cmake -S /InsightToolkit-5.3.0 -B /InsightToolkit-5.3.0/build -DCMAKE_BUILD_TYPE=Release \
 && sed -i '1 i\#include <stdint.h>' /InsightToolkit-5.3.0/Modules/Core/Common/include/itkFloatingPointExceptions.h \
 && sed -i '1 i\#include <stdint.h>' /InsightToolkit-5.3.0/Modules/Filtering/MathematicalMorphology/include/itkMathematicalMorphologyEnums.h \
 && cmake --build /InsightToolkit-5.3.0/build --parallel "$(nproc)" --verbose \
 && cmake --install /InsightToolkit-5.3.0/build \
 && rm -rf /InsightToolkit-5.3.0 /InsightToolkit-5.3.0.tar.gz

RUN git clone https://github.com/STORM-IRIT/OpenGR.git --depth 1 \
 && cmake -S /OpenGR -B /OpenGR/build \
 && cmake --build /OpenGR/build --parallel "$(nproc)" \
 && cmake --install /OpenGR/build \
 && mkdir -p /usr/local/lib/cmake/opengr \
 && rm -rf /OpenGR

RUN git clone https://github.com/ethz-asl/libnabo.git --depth 1 \
 && cmake -S /libnabo -B /libnabo/build -DCMAKE_BUILD_TYPE=Release -DUSE_OPEN_MP=False \
 && cmake --build /libnabo/build --parallel "$(nproc)" \
 && cmake --install /libnabo/build \
 && rm -rf /libnabo

RUN git clone https://github.com/ethz-asl/libpointmatcher.git \
 && git -C /libpointmatcher switch -d 3eb448330b \
 && sed -i 's/Boost_USE_STATIC_LIBS  ON/Boost_USE_STATIC_LIBS  OFF/' /libpointmatcher/CMakeLists.txt \
 && sed -i 's/thread system/thread/' /libpointmatcher/libpointmatcherConfig.cmake.in /libpointmatcher/CMakeLists.txt \
 && cmake -S /libpointmatcher -B /libpointmatcher/build -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=OFF -DBUILD_EVALUATIONS=OFF \
 && cmake --build /libpointmatcher/build --parallel "$(nproc)" \
 && cmake --install /libpointmatcher/build \
 && rm -rf /libpointmatcher
 # Commit 3eb448330b is 1.4.4

RUN git clone --recursive https://github.com/oxfordcontrol/osqp  --depth 1 \
 && cmake -S /osqp -B /osqp/build \
 && cmake --build /osqp/build --parallel "$(nproc)" \
 && cmake --install /osqp/build \
 && rm -rf /osqp

RUN git clone https://github.com/scipopt/soplex --depth 1 \
 && cmake -S /soplex -B /soplex/build \
 && cmake --build /soplex/build --parallel "$(nproc)" \
 && cmake --install /soplex/build \
 && rm -rf /soplex

RUN git clone https://github.com/scipopt/scip --depth 1 \
 && cmake -S /scip -B /scip/build -DAUTOBUILD=ON \
 && cmake --build /scip/build --parallel "$(nproc)" \
 && cmake --install /scip/build \
 && rm -rf /scip

RUN git clone https://ceres-solver.googlesource.com/ceres-solver \
 && git -C /ceres-solver checkout 2.2.0 \
 && cmake -S /ceres-solver -B /ceres-solver/build -DMINIGLOG=ON -DMINIGLOG_MAX_LOG_LEVEL=0 \
 && cmake --build /ceres-solver/build --parallel "$(nproc)" \
 && cmake --install /ceres-solver/build \
 && rm -rf /ceres-solver

RUN  git clone https://github.com/fastfloat/fast_float \
 &&  git -C /fast_float checkout v8.3.3 \
 &&  cmake -S /fast_float -B /fast_float/build \
 &&  cmake --build /fast_float/build --parallel "$(nproc)" \
 &&  cmake --install /fast_float/build \
 && rm -rf /fast_float

ENV CGAL_TEST_PLATFORM="Ubuntu-Latest"
ENV CGAL_SUMMARY_NAME="Ubuntu-latest-Debug"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt5:BOOL=OFF\")"
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

COPY --from=root Ubuntu/toolbox-setup.sh /tmp/toolbox-setup.sh
RUN sh /tmp/toolbox-setup.sh && rm /tmp/toolbox-setup.sh
