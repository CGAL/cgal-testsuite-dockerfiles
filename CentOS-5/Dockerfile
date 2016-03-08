FROM centos:centos5
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

RUN yum -y update; yum clean all
RUN yum -y install \
    cmake \
    curl \
    gcc-c++ \
    glibc-devel.x86_64 \
    gmp-devel.x86_64 \
    libstdc++-devel.x86_64 \
    make \
    qt-devel.x86_64 \
    qt4-devel.x86_64 \
    tar \
    zlib-devel.x86_64
RUN yum clean all
RUN ln -s /usr/lib64/qt4/bin/qmake /usr/bin/qmake-qt4

RUN curl -s -SL http://bitbucket.org/eigen/eigen/get/3.2.8.tar.gz | tar xz && \
    mkdir -p /usr/local/include/eigen3 && \
    cd eigen-eigen-07105f7124f9 && \
    cp -R Eigen/ /usr/local/include/eigen3 && \
    cp -R unsupported /usr/local/include/eigen3 && \
    cp -R signature_of_eigen3_matrix_library /usr/local/include/eigen3

ENV BOOST_MAJOR=1 BOOST_MINOR=48 BOOST_PATCH=0
RUN curl -s -SL http://sourceforge.net/projects/boost/files/boost/${BOOST_MAJOR}.${BOOST_MINOR}.${BOOST_PATCH}/boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH}.tar.gz | tar xz
RUN cd boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH} && \
    ./bootstrap.sh --without-libraries=filesystem,graph_parallel,python,iostreams,locale,mpi,serialization,signals,wave && \
    ./b2 --prefix=/usr/local/ install

RUN curl -s -k -SL -O http://www.cmake.org/files/v2.8/cmake-2.8.11.tar.gz && \
    sha256sum -c - <<< "20d0d3661797fa82c19e7a75c7315c640e001cb3238331ca170bb0fae27feee5  cmake-2.8.11.tar.gz" && \
    tar xzf cmake-2.8.11.tar.gz && \
    cd cmake-2.8.11 && ./configure && make -j4 && make install && \
    cd .. && rm -rf cmake-2.8.11*

ENV CGAL_TEST_PLATFORM="CentOS5"
ENV CGAL_CMAKE_FLAGS="()"
