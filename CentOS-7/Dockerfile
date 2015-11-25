FROM centos:centos7
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

RUN yum -y update; yum clean all
RUN yum -y install epel-release.noarch
RUN yum -y update; yum -y install \
    boost-devel.x86_64 \
    cmake \
    curl \
    eigen3-devel.noarch \
    gcc-c++ \
    glew-devel.x86_64 \
    glibc-devel.x86_64 \
    gmp-devel.x86_64 \
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
RUN yum clean all

RUN curl -s -SL http://www.libqglviewer.com/src/libQGLViewer-2.6.1.tar.gz | tar xzv && \
    cd libQGLViewer-2.6.1 && \
    qmake-qt4 -o Makefile libQGLViewer-2.6.1.pro && \
    make install && cd / && rm -rf libQGLViewer-2.6.1

RUN cd /etc/yum.repos.d/ && \
    curl -s -SLO https://copr.fedoraproject.org/coprs/rineau/libQGLViewer-qt5/repo/epel-7/rineau-libQGLViewer-qt5-epel-7.repo && \
    rpm --import https://copr-be.cloud.fedoraproject.org/results/rineau/libQGLViewer-qt5/pubkey.gpg && \
    yum -y install libQGLViewer-qt5-devel.x86_64

ENV CGAL_TEST_PLATFORM="CentOS7"
ENV CGAL_CMAKE_FLAGS=""
