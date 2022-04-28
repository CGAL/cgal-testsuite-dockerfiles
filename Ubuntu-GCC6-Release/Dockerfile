FROM cgal/testsuite-docker:ubuntu-gcc6
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="Ubuntu-latest-GCC6-Release"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DDONT_USE_BOOST_PROGRAM_OPTIONS -Wall -Wextra -O3 -DCGAL_NDEBUG\" \"-DWITH_CGAL_Qt3:BOOL=OFF\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
