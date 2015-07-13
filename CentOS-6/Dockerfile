FROM centos:centos6
MAINTAINER Laurent Rineau <laurent.rineau@cgal.org>

RUN yum -y update; yum clean all
RUN yum -y install epel-release.noarch
RUN yum -y update; yum -y install \
    cmake \
    curl \
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
    qt5-qtbase-devel.x86_64 \
    qt5-qtscript-devel.x86_64 \
    qt5-qtsvg-devel.x86_64 \
    qt5-qttools-devel.x86_64 \
    tar \
    zlib-devel.x86_64
RUN yum clean all

ENV BOOST_MAJOR=1 BOOST_MINOR=48 BOOST_PATCH=0
RUN curl -SL http://sourceforge.net/projects/boost/files/boost/${BOOST_MAJOR}.${BOOST_MINOR}.${BOOST_PATCH}/boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH}.tar.gz | tar xz
RUN cd boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH} && \
    ./bootstrap.sh --without-libraries=filesystem,graph_parallel,python,iostreams,locale,mpi,serialization,signals,wave && \
    ./b2 --prefix=/usr/local/ install

ENV CGAL_TEST_PLATFORM="CentOS6"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\")"
