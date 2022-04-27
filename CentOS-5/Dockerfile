FROM centos:centos5
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN yum -y update; yum clean all
RUN yum -y install \
    curl \
    gcc-c++ \
    glibc-devel.x86_64 \
    gmp-devel.x86_64 \
    libstdc++-devel.x86_64 \
    make \
    tar \
    zlib-devel.x86_64; yum clean all

RUN curl -s -SL http://bitbucket.org/eigen/eigen/get/3.2.8.tar.gz | tar xz && \
    mkdir -p /usr/local/include/eigen3 && \
    cd eigen-* && \
    cp -R Eigen/ /usr/local/include/eigen3 && \
    cp -R unsupported /usr/local/include/eigen3 && \
    cp -R signature_of_eigen3_matrix_library /usr/local/include/eigen3 && \
    cd .. && \
    rm -rf eigen*

ENV BOOST_MAJOR=1 BOOST_MINOR=48 BOOST_PATCH=0
RUN curl -s -SL http://sourceforge.net/projects/boost/files/boost/${BOOST_MAJOR}.${BOOST_MINOR}.${BOOST_PATCH}/boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH}.tar.gz | tar xz && \
    cd boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH} && \
    ./bootstrap.sh --without-libraries=filesystem,graph_parallel,python,iostreams,locale,mpi,serialization,signals,wave && \
    ./b2 -d0 --prefix=/usr/local/ install && \
    cd .. && \
    rm -rf boost_*

RUN curl -s -k -SL "https://cmake.org/files/v3.1/cmake-3.1.3-Linux-x86_64.sh" -o cmake.sh && bash cmake.sh --skip-license && rm cmake.sh

ENV CGAL_TEST_PLATFORM="CentOS5"
ENV CGAL_CMAKE_FLAGS="()"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

LABEL org.cgal.releases_to_ignore="^[5-9]"
