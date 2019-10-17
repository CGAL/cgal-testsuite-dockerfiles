FROM cgal/testsuite-docker:fedora
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

ENV CGAL_TEST_PLATFORM="Fedora-Release"
ENV CGAL_CMAKE_FLAGS="('-DCMAKE_BUILD_TYPE=Release' '-DCMAKE_CXX_FLAGS_RELEASE=-msse3 -O3 -DCGAL_NDEBUG' '-DWITH_GMPXX=ON')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
