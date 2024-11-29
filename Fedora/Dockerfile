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
    zlib-ng-devel.x86_64 \
    diffutils.x86_64 \
    git \
    libssh-devel \
    lsb-release \
    json-devel

RUN wget https://github.com/sloriot/LAStools/archive/refs/heads/fix_make_install.zip \
 && unzip fix_make_install.zip \
 && cd LAStools-fix_make_install \
 && mkdir build \
 && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release .. \
 && make -j "$(nproc)" \
 && make install \
 && cd .. \
 && rm -rf LAStools-fix_make_install fix_make_install.zip



ENV CGAL_TEST_PLATFORM="Fedora"
ENV CGAL_SUMMARY_NAME="Fedora-latest-Debug"
ENV CGAL_CMAKE_FLAGS=""
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
