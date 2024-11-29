FROM fedora:rawhide
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN dnf -y upgrade && \
    [ -x /usr/bin/dnf ] || ln -s /usr/bin/dnf5 /usr/bin/dnf && \
    dnf -y install make cmake gcc-c++ \
                   util-linux \
                   gmp-devel.x86_64 mpfr-devel.x86_64 \
                   boost-devel.x86_64 \
                   ntl-devel.x86_64 \
                   ipe-devel.x86_64 \
                   eigen3-devel.noarch \
                   qt5-qtbase-devel.x86_64 \
                   qt5-qtscript-devel.x86_64 \
                   qt5-qtsvg-devel.x86_64 \
                   qt5-qttools-devel.x86_64 \
                   qt6-qtbase-devel.x86_64 \
                   qt6-qtsvg-devel.x86_64 \
                   qt6-qttools-devel.x86_64 \
                   mesa-libGLU-devel \
                   OpenMesh-devel \
                   zlib-ng-devel.x86_64 \
		           diffutils \
                   wget \
                   git \
                   lsb-release \
                   json-devel \
                   tar && \
    dnf clean all && \
    wget https://github.com/oneapi-src/oneTBB/archive/refs/tags/v2021.8.0.tar.gz && \
    tar xf v2021.8.0.tar.gz && \
    mkdir build && \
    cd build && \
    sed -i '1i #include <cstdlib>' /oneTBB-2021.8.0/test/common/utils_assert.h && \
    cmake -DCMAKE_BUILD_TYPE=Release -DTBB_STRICT:BOOL=OFF -DTBB_TEST:BOOL=OFF ../oneTBB-2021.8.0 && \
    make && \
    make install && \
    cd .. && rm -rf v2021.8.0.tar.gz oneTBB-2021.8.0 build

ENV CGAL_TEST_PLATFORM="Fedora-rawhide"
ENV CGAL_SUMMARY_NAME="Fedora-testing-Debug"
ENV CGAL_CMAKE_FLAGS="('-DCGAL_HEADER_ONLY:BOOL=TRUE')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
