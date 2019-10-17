FROM cgal/testsuite-docker:ubuntu
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

ENV CGAL_TEST_PLATFORM="Ubuntu-Latest-CXX11"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-std=c++11 -fext-numeric-literals\" \"-DWITH_CGAL_Qt3:BOOL=OFF\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
