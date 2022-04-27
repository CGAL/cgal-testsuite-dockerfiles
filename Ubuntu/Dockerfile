FROM ubuntu:latest
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential cmake \
    libopencv-dev \
    libsuitesparse-dev \
    tar \
    libboost-all-dev libgmp10-dev \
    libmpfr-dev zlib1g-dev \
    libeigen3-dev libipe-dev \
    libmpfi-dev libqglviewer-dev-qt5 \
    libinsighttoolkit4-dev libtbb-dev git

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

RUN git clone https://github.com/ethz-asl/libnabo.git \
 && cd libnabo \
 && SRC_DIR=`pwd` && BUILD_DIR=${SRC_DIR}/build \
 && mkdir -p ${BUILD_DIR} && cd ${BUILD_DIR} \
 && cmake -DCMAKE_BUILD_TYPE=Release ${SRC_DIR} \
 && make && make install \
 && cd ../.. && rm -rf libnado

RUN git clone https://github.com/ethz-asl/libpointmatcher.git \
 && cd libpointmatcher \
 && SRC_DIR=`pwd` \
 && BUILD_DIR=${SRC_DIR}/build \
 && mkdir -p ${BUILD_DIR} && cd ${BUILD_DIR} \
 && cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release ${SRC_DIR} \
 && make -j"$(nproc)" && make install \
 && cd ../.. && rm -rf libpointmatcher
 
RUN git clone --recursive https://github.com/oxfordcontrol/osqp \
 && cd ./osqp \
 && mkdir build \
 && cd build \
 && cmake .. \
 && make -j"$(nproc)" \
 && make install \
 && cd ../.. \
 && rm -rf osqp

ENV CGAL_TEST_PLATFORM="Ubuntu-Latest"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt5:BOOL=OFF\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
