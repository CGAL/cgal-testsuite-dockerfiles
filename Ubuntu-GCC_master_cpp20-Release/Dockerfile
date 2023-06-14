FROM cgal/testsuite-docker:ubuntu-gcc6
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="Ubuntu-GCC_master_CXX20-Release"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DDONT_USE_BOOST_PROGRAM_OPTIONS -Wall -Wextra -std=c++2a -O3 -DCGAL_NDEBUG\" \"-DCMAKE_PREFIX_PATH=/usr/local/boost\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

LABEL org.cgal.releases_to_ignore="^(4|5\\.0)"
