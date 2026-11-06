# This Dockerfile builds on a base variant.
# Build with: docker build --target cgal-base (or --target cgal-toolbox)
# See the base variant Dockerfile for multi-stage definitions.

ARG base_image=cgal/testsuite-docker:ubuntu-gcc6
FROM ${base_image}
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url
ARG image_tag
ENV IMAGE_TAG=$image_tag

ENV CGAL_TEST_PLATFORM="Ubuntu-latest-GCC6-CXX1z"
ENV CGAL_SUMMARY_NAME="Ubuntu-latest-GCC_master-CXX1z"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DDONT_USE_BOOST_PROGRAM_OPTIONS -Wall -Wextra -std=c++1z\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
