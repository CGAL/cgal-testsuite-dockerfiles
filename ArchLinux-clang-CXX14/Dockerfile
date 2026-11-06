# This Dockerfile builds on a base variant.
# Build with: docker build --target cgal-base (or --target cgal-toolbox)
# See the base variant Dockerfile for multi-stage definitions.

ARG base_image=cgal/testsuite-docker:archlinux-clang
FROM ${base_image} AS cgal-base
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="ArchLinux-clang-CXX14"
ENV CGAL_SUMMARY_NAME="ArchLinux-basedevel-clang-CXX14"
ENV CGAL_CMAKE_FLAGS="(\"-DCMAKE_CXX_FLAGS_DEBUG="" \" \"-DCMAKE_C_COMPILER:FILEPATH=/bin/clang\" \"-DCMAKE_CXX_COMPILER:FILEPATH=/bin/clang++\" \"-DCGAL_CXX_FLAGS=-Wall -std=c++14\")" CXX=/bin/clang++ CC=/bin/clang
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

# ===== STAGE 2: Toolbox Variant =====
# Derived from cgal-base with toolbox label
FROM cgal-base AS cgal-toolbox

LABEL com.github.containers.toolbox="true" \
      name="cgal-toolbox" \
      usage="This image is meant to be used with the toolbox command"
