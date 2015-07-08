FROM centos:centos6
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

RUN yum -y update; yum clean all
RUN yum -y install epel-release.noarch
RUN yum -y update; yum -y install \
                   cmake \
                   eigen3-devel.noarch \
                   gcc-c++ \
                   glew-devel.i686 \
                   glibc-devel.i686 \
                   glibc-devel.x86_64 \
                   gmp-devel.i686 \
                   libQGLViewer-devel.i686 \
                   libstdc++-devel.i686 \
                   libstdc++-devel.x86_64 \
                   make \
                   mpfr-devel.i686 \
                   qt-devel.i686 \
                   tar \
                   zlib-devel.i686
RUN yum clean all

ENV BOOST_MAJOR=1 BOOST_MINOR=48 BOOST_PATCH=0
RUN curl -SL http://sourceforge.net/projects/boost/files/boost/${BOOST_MAJOR}.${BOOST_MINOR}.${BOOST_PATCH}/boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH}.tar.gz | tar xz
RUN cd boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH} && \
    ./bootstrap.sh --without-libraries=filesystem,graph_parallel,python,iostreams,locale,mpi,serialization,signals,wave && \
    ./b2 cflags=-m32 \
         cxxflags=-m32 \
         address-model=32 \
         threading=multi \
         architecture=x86 \
         instruction-set=i686 \
         --prefix=/usr/local/ install

ENV CC="gcc -m32" CXX="g++ -m32"
ENV CGAL_TEST_PLATFORM="CentOS6-32"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\")"
