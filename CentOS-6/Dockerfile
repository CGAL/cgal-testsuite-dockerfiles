FROM centos:centos6
ARG dockerfile_url

RUN yum -y install epel-release.noarch; yum -y update; yum clean all
RUN yum -y install \
    curl \
    eigen3-devel.noarch \
    gcc-c++ \
    glew-devel.x86_64 \
    glibc-devel.x86_64 \
    gmp-devel.x86_64 \
    libstdc++-devel.x86_64 \
    make \
    mpfr-devel.x86_64 \
    ntl-devel.x86_64 \
    qt5-qtbase-devel.x86_64 \
    qt5-qtscript-devel.x86_64 \
    qt5-qtsvg-devel.x86_64 \
    qt5-qttools-devel.x86_64 \
    tar \
    zlib-devel.x86_64 && yum clean all

RUN curl -fSL "https://cmake.org/files/v3.1/cmake-3.1.3-Linux-x86_64.sh" -o cmake.sh && bash cmake.sh --skip-license && rm cmake.sh

ENV BOOST_MAJOR=1 BOOST_MINOR=55 BOOST_PATCH=0
RUN curl -s -SL http://sourceforge.net/projects/boost/files/boost/${BOOST_MAJOR}.${BOOST_MINOR}.${BOOST_PATCH}/boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH}.tar.gz | tar xz && \
    cd boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH} && \
    ./bootstrap.sh --without-libraries=graph_parallel,python,iostreams,locale,mpi,serialization,signals,wave && \
    ./b2 -d0 --prefix=/usr/local/ install && \
    cd .. && rm -rf boost_*

RUN cd /etc/yum.repos.d/ && \
    curl -s -SLO https://copr.fedoraproject.org/coprs/rineau/libQGLViewer-qt5/repo/epel-6/rineau-libQGLViewer-qt5-epel-6.repo && \
    rpm --import https://copr-be.cloud.fedoraproject.org/results/rineau/libQGLViewer-qt5/pubkey.gpg && \
    yum -y install libQGLViewer-qt5-devel.x86_64 libQGLViewer-devel.x86_64 && \
    yum clean all

ENV CGAL_TEST_PLATFORM="CentOS6"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

LABEL org.cgal.releases_to_ignore="^[5-9]"
