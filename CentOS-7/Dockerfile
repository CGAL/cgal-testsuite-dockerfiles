FROM centos:centos7
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN yum -y update; yum clean all
RUN yum -y install epel-release.noarch; yum clean all
RUN yum -y update; yum -y install \
    boost-devel.x86_64 \
    curl \
    eigen3-devel.noarch \
    gcc-c++ \
    metis-devel \
    glew-devel.x86_64 \
    glibc-devel.x86_64 \
    gmp-devel.x86_64 \
    libstdc++-devel.x86_64 \
    tbb-devel \
    make \
    mpfr-devel.x86_64 \
    qt5-qtbase-devel.x86_64 \
    qt5-qtscript-devel.x86_64 \
    qt5-qtsvg-devel.x86_64 \
    qt5-qttools-devel.x86_64 \
    qt6-qtbase-devel.x86_64 \
    qt6-qtsvg-devel.x86_64 \
    qt6-qttools-devel.x86_64 \
    tar \
    git \
    zlib-devel.x86_64; yum clean all

RUN curl -fSL "https://cmake.org/files/v3.6/cmake-3.6.2-Linux-x86_64.sh" -o /usr/cmake.sh
RUN cd /usr \
 && chmod +x ./cmake.sh

RUN cd /usr \
&& ./cmake.sh --skip-license

#
# The CMAKE_GENERATOR trick is used to pass a CMake variable to each CMake
# run by the testsuite.
#
ENV CGAL_TEST_PLATFORM="CentOS7" CMAKE_GENERATOR="-DCMAKE_POLICY_DEFAULT_CMP0054=OLD"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

LABEL org.cgal.releases_to_ignore="^[5-9]"
