FROM centos:centos6
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN yum -y install epel-release.noarch; yum -y update; yum clean all
RUN yum -y update; yum -y install \
                   eigen3-devel.noarch \
                   gcc-c++ \
                   glew-devel.i686 \
                   glibc-devel.i686 \
                   glibc-devel.x86_64 \
                   gmp-devel.i686 \
                   libstdc++-devel.i686 \
                   libstdc++-devel.x86_64 \
                   make \
                   mpfr-devel.i686 \
                   ntl-devel.i686 \
                   mesa-libGL-devel.i686 \
                   mesa-libGLU-devel.i686 \
                   qt5-qtbase-devel.i686 \
                   qt5-qtscript-devel.i686 \
                   qt5-qtsvg-devel.i686 \
                   qt5-qttools-devel.i686 \
                   tar \
                   zlib-devel.i686 && yum clean all

RUN curl -fSL "https://cmake.org/files/v3.1/cmake-3.1.3-Linux-i386.sh" -o cmake.sh && bash cmake.sh --skip-license && rm cmake.sh

ENV BOOST_MAJOR=1 BOOST_MINOR=48 BOOST_PATCH=0
RUN curl -s -SL http://sourceforge.net/projects/boost/files/boost/${BOOST_MAJOR}.${BOOST_MINOR}.${BOOST_PATCH}/boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH}.tar.gz | tar xz && \
    cd boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH} && \
    ./bootstrap.sh --without-libraries=graph_parallel,python,iostreams,locale,mpi,serialization,signals,wave && \
    ./b2 -d0 \
         cflags=-m32 \
         cxxflags=-m32 \
         address-model=32 \
         threading=multi \
         architecture=x86 \
         instruction-set=i686 \
         --prefix=/usr/local/ install && \
    cd .. && rm -rf boost_*

ENV CC="gcc -m32" CXX="g++ -m32"
ENV CGAL_TEST_PLATFORM="CentOS6-32"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

LABEL org.cgal.releases_to_ignore="^[5-9]"
