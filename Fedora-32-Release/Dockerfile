# This Dockerfile builds on a base variant.
# Build with: docker build --target cgal-base (or --target cgal-toolbox)
# See the base variant Dockerfile for multi-stage definitions.

ARG base_image=cgal/testsuite-docker:fedora-32
FROM ${base_image}
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url
ARG image_tag
ENV IMAGE_TAG=$image_tag

ENV CGAL_TEST_PLATFORM="Fedora-32-Release"
ENV CGAL_SUMMARY_NAME="Fedora-latest-32-Release"
ENV CGAL_CMAKE_FLAGS="('-DCMAKE_BUILD_TYPE=Release' '-DCMAKE_CXX_FLAGS_RELEASE=-O3 -DCGAL_NDEBUG')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
