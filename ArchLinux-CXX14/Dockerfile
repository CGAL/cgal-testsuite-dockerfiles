FROM cgal/testsuite-docker:archlinux
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="ArchLinux-CXX14"
ENV CGAL_SUMMARY_NAME="ArchLinux-basedevel-CXX14"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_HEADER_ONLY=OFF\" \"-DCGAL_CXX_FLAGS=-Wall -std=gnu++14\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
