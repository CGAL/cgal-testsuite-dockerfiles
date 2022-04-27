FROM cgal/testsuite-docker:fedora
ARG dockerfile_url

ENV CGAL_TEST_PLATFORM="Fedora-strict-ansi"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-Wall -Wextra -ansi\" \"-DWITH_CGAL_Qt3:BOOL=OFF\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
