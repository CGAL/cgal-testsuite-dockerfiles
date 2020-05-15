FROM cgal/testsuite-docker:ubuntu-gcc6
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

ENV CGAL_TEST_PLATFORM="Ubuntu-GCC_master_CXX20-Release"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DDONT_USE_BOOST_PROGRAM_OPTIONS -Wall -Wextra -std=c++2a -O3 -DCGAL_NDEBUG\" \"-DWITH_CGAL_Qt3:BOOL=OFF\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
