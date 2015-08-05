FROM fedora:latest
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

RUN dnf -y update; dnf clean all
RUN dnf -y install \
    boost-devel.i686 \
    cmake \
    eigen3-devel.noarch \
    gcc-c++.i686 \
    gcc-c++.x86_64 \
    glew-devel.i686 \
    glibc-devel.i686 \
    gmp-devel.i686 \
    ipe-devel.i686 \
    libQGLViewer-devel.i686 \
    libstdc++-devel.i686 \
    libstdc++-devel.x86_64 \
    make \
    mesa-libGL-devel.i686 \
    mpfr-devel.i686 \
    qt-devel.i686 \
    qt3-devel.i686 \
    qt5-qtbase-devel.i686 \
    qt5-qtscript-devel.i686 \
    qt5-qtsvg-devel.i686 \
    qt5-qttools-devel.i686 \
    tar \
    zlib-devel.i686

# RUN dnf -y install 'dnf-command(copr)'
# RUN rpm --import https://copr-be.cloud.fedoraproject.org/results/rineau/libQGLViewer-qt5/pubkey.gpg
# RUN dnf -y copr enable rineau/libQGLViewer-qt5 && dnf -y install libQGLViewer-qt5-devel.i386

RUN dnf clean all

ENV CC="gcc -m32" CXX="g++ -m32" QTDIR=/usr/lib/qt-3.3
ENV CGAL_TEST_PLATFORM="Fedora-32"
ENV CGAL_CMAKE_FLAGS="()"
