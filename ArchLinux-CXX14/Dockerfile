# This Dockerfile builds on a base variant.
# Build with: docker build --target cgal-base (or --target cgal-toolbox)
# See the base variant Dockerfile for multi-stage definitions.

ARG base_image=cgal/testsuite-docker:archlinux
FROM ${base_image} AS cgal-base
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="ArchLinux-CXX14"
ENV CGAL_SUMMARY_NAME="ArchLinux-basedevel-CXX14"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_HEADER_ONLY=OFF\" \"-DCGAL_CXX_FLAGS=-Wall -std=gnu++14\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

# ===== STAGE 2: Toolbox Variant =====
# Derived from cgal-base with toolbox label
FROM cgal-base AS cgal-toolbox

LABEL com.github.containers.toolbox="true" \
      name="cgal-toolbox" \
      usage="This image is meant to be used with the toolbox command"
