FROM fedora:latest
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN dnf -y update; dnf clean all
RUN dnf -y install \
    boost-devel.x86_64 \
    cmake \
    eigen3-devel.noarch \
    gcc-c++ \
    glew-devel.x86_64 \
    gmp-devel.x86_64 \
    ipe-devel.x86_64 \
    OpenMesh-devel \
    opencv-devel \
    make \
    mpfr-devel.x86_64 \
    mpfi-devel.x86_64 \
    ntl-devel.x86_64 \
    qt5-qtbase-devel.x86_64 \
    qt5-qtscript-devel.x86_64 \
    qt5-qtsvg-devel.x86_64 \
    qt5-qttools-devel.x86_64 \
    qt6-qtbase-devel.x86_64 \
    qt6-qtsvg-devel.x86_64 \
    qt6-qttools-devel.x86_64 \
    qt6-qtwebsockets-devel.x86_64 \
    qt6-qtdeclarative-devel.x86_64 \
    tar \
    unzip \
    wget \
    tbb-devel \
    zlib-devel.x86_64 \
    diffutils.x86_64 \
    libssh-devel

RUN wget "https://github.com/CGAL/LAStools/archive/LAStools-2020-11-09.zip" -O laslib.zip \
 && unzip laslib.zip \
 && cd ./LAStools-LAStools-2020-11-09 \
 && cmake -DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/g++ -DCMAKE_CXX_FLAGS=-std=c++11 . \
 && make -j "$(nproc)" \
 && make install \
 && cd .. \
 && rm -rf LAStools-LAStools-2020-11-09 \
 && rm -rf laslib.zip


ENV CGAL_TEST_PLATFORM="Fedora"
ENV CGAL_CMAKE_FLAGS=""
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
