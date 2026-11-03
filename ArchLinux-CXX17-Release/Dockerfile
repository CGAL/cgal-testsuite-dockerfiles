# This Dockerfile builds on a base variant.
# Build with: docker build --target cgal-base (or --target cgal-toolbox)
# See the base variant Dockerfile for multi-stage definitions.

FROM cgal/testsuite-docker:archlinux
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="ArchLinux-CXX17-Release"
ENV CGAL_SUMMARY_NAME="ArchLinux-basedevel-CXX17"
ENV CGAL_CMAKE_FLAGS="(\"-DCMAKE_CXX_FLAGS=-Wall -O3 -msse4.1 -std=gnu++17\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
