FROM cgal/testsuite-docker:centos7
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

ENV CGAL_TEST_PLATFORM="CentOS7-Release"
ENV CGAL_CMAKE_FLAGS="('-DCMAKE_BUILD_TYPE=Release' '-DCMAKE_CXX_FLAGS_RELEASE=-O3 -DCGAL_NDEBUG')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
