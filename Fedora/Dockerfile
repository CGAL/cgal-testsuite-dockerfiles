FROM fedora:latest
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

RUN dnf -y update; dnf clean all
RUN dnf -y install \
    boost-devel.x86_64 \
    cmake \
    eigen3-devel.noarch \
    gcc-c++ \
    glew-devel.x86_64 \
    glibc-devel.x86_64 \
    gmp-devel.x86_64 \
    libQGLViewer-devel.x86_64 \
    libstdc++-devel.x86_64 \
    make \
    mpfr-devel.x86_64 \
    qt-devel.x86_64 \
    qt3-devel.x86_64 \
    qt5-qtbase-devel.x86_64 \
    qt5-qtscript-devel.x86_64 \
    qt5-qtsvg-devel.x86_64 \
    qt5-qttools-devel.x86_64 \
    tar \
    zlib-devel.x86_64

RUN dnf -y install 'dnf-command(copr)'
RUN rpm --import https://copr-be.cloud.fedoraproject.org/results/rineau/libQGLViewer-qt5/pubkey.gpg
RUN dnf -y copr enable rineau/libQGLViewer-qt5 && dnf -y install libQGLViewer-qt5-devel.x86_64

RUN dnf clean all

ENV CGAL_TEST_PLATFORM="Fedora"
ENV CGAL_CMAKE_FLAGS=""
