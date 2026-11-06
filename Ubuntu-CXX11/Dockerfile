# This Dockerfile builds on a base variant.
# Build with: docker build --target cgal-base (or --target cgal-toolbox)
# See the base variant Dockerfile for multi-stage definitions.

ARG base_image=cgal/testsuite-docker:ubuntu
FROM ${base_image}
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url
ARG image_tag
ENV IMAGE_TAG=$image_tag

ENV CGAL_TEST_PLATFORM="Ubuntu-Latest-CXX11"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-std=c++11 -fext-numeric-literals\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
