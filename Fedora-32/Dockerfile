FROM fedora:latest
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN dnf -y update; dnf clean all
RUN dnf -y install \
    util-linux \
    boost-devel.i686 \
    cmake \
    eigen3-devel.noarch \
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
    ntl-devel.i686 \
    tar \
    tbb-devel.i686 \
    diffutils \
    git \
    lsb-release \
    json-devel \
    zlib-ng-devel.i686 && dnf clean all

ENV CC="gcc -m32" CXX="g++ -m32"
ENV CGAL_TEST_PLATFORM="Fedora-32"
ENV CGAL_CMAKE_FLAGS="('-DCGAL_HEADER_ONLY:BOOL=TRUE')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
