FROM cgal/testsuite-docker:debian-stable
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

ENV CGAL_TEST_PLATFORM="Debian-stable-Release"
ENV CGAL_CMAKE_FLAGS="('-DCMAKE_BUILD_TYPE=Release' '-DCMAKE_CXX_FLAGS_RELEASE=-O3 -DCGAL_NDEBUG' '-DWITH_CGAL_Qt3:BOOL=OFF')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
