FROM cgal/testsuite-docker:fedora-rawhide
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

ENV CGAL_TEST_PLATFORM="Fedora-rawhide-Release"
ENV CGAL_CMAKE_FLAGS="('-DCMAKE_BUILD_TYPE=Release' '-DCMAKE_CXX_FLAGS_RELEASE=-O3 -DCGAL_NDEBUG')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
