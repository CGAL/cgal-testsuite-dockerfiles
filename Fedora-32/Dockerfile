FROM fedora:latest AS cgal-common

RUN dnf -y update; dnf clean all
RUN dnf -y install \
    awk util-linux \
    boost-devel.i686 \
    cmake \
    eigen3-devel.noarch \
    libatomic.i686 \
    gcc-c++.i686 \
    gcc-c++.x86_64 \
    glew-devel.i686 \
    glibc-devel.i686 \
    gmp-devel.i686 \
    libstdc++-devel.i686 \
    libstdc++-devel.x86_64 \
    make \
    mesa-libGL-devel.i686 \
    mesa-libGLU-devel.i686 \
    mpfr-devel.i686 \
    tar \
    tbb-devel.i686 \
    diffutils \
    git \
    lsb-release \
    json-devel \
    'zlib-static(x86-32)' \
    'zlib-devel(x86-32)' && dnf clean all

RUN  git clone https://github.com/fastfloat/fast_float \
 &&  cd fast_float \
 &&  git checkout v8.3.3 \
 &&  mkdir build \
 &&  cd build \
 &&  cmake .. \
 &&  make install \
 && cd .. && rm -rf fast_float

ENV CC="gcc -m32" CXX="g++ -m32"
ENV CGAL_TEST_PLATFORM="Fedora-32"
ENV CGAL_SUMMARY_NAME="Fedora-latest-32-Debug"
ENV CGAL_CMAKE_FLAGS="('-DCGAL_HEADER_ONLY:BOOL=TRUE')"
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

COPY --from=root Fedora/toolbox-setup.sh /tmp/toolbox-setup.sh
RUN sh /tmp/toolbox-setup.sh && rm /tmp/toolbox-setup.sh
