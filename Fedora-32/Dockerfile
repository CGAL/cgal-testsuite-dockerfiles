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
    ipe.i686 \
    ipe-devel.i686 \
    libstdc++-devel.i686 \
    libstdc++-devel.x86_64 \
    make \
    mesa-libGL-devel.i686 \
    mesa-libGLU-devel.i686 \
    mpfr-devel.i686 \
    ntl-devel.i686 \
    qt-devel.i686 \
    qt3-devel.i686 \
    qt5-qtbase-devel.i686 \
    qt5-qtscript-devel.i686 \
    qt5-qtsvg-devel.i686 \
    qt5-qttools-devel.i686 \
    tar \
    tbb-devel.i686 \
    diffutils \
    zlib-devel.i686 && dnf clean all

RUN ln -s /usr/lib64/qt5/bin/qhelpgenerator /usr/lib/qt5/bin/qhelpgenerator

ENV CC="gcc -m32" CXX="g++ -m32" QTDIR=/usr/lib/qt-3.3
ENV CGAL_TEST_PLATFORM="Fedora-32"
ENV CGAL_CMAKE_FLAGS="('-DCGAL_HEADER_ONLY:BOOL=TRUE')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
