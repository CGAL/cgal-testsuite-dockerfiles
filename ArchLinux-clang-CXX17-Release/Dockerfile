# This Dockerfile builds on a base variant.
# Build with: docker build --target cgal-base (or --target cgal-toolbox)
# See the base variant Dockerfile for multi-stage definitions.

ARG base_image=cgal/testsuite-docker:archlinux-clang
FROM ${base_image}
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="ArchLinux-clang-CXX17-Release"
ENV CGAL_SUMMARY_NAME="ArchLinux-basedevel-clang-CXX17"
ENV CGAL_CMAKE_FLAGS="(\"-DCMAKE_CXX_FLAGS_DEBUG="" \" \"-DCMAKE_C_COMPILER:FILEPATH=/bin/clang\" \"-DCMAKE_CXX_COMPILER:FILEPATH=/bin/clang++\" \"-DCMAKE_CXX_FLAGS=-Wall -O3 -std=c++17\")" CXX=/bin/clang++ CC=/bin/clang
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
