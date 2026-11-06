# This Dockerfile builds on a base variant.
# Build with: docker build --target cgal-base (or --target cgal-toolbox)
# See the base variant Dockerfile for multi-stage definitions.

ARG base_image=cgal/testsuite-docker:fedora
FROM ${base_image} AS cgal-base
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url
ARG image_tag
ENV IMAGE_TAG=$image_tag

ENV CGAL_TEST_PLATFORM="Fedora-with-LEDA"
ENV CGAL_SUMMARY_NAME="Fedora-latest-With-LEDA"
ENV LEDA_DIR="/mnt/testresults/leda-numbers/" LD_LIBRARY_PATH=/mnt/testresults/leda-numbers/
ENV INIT_FILE=/tmp/init.cmake
ENV CGAL_DISABLE_GMP=ON
COPY init.cmake /tmp/init.cmake

# ===== STAGE 2: Toolbox Variant =====
# Derived from cgal-base with toolbox label
FROM cgal-base AS cgal-toolbox

LABEL com.github.containers.toolbox="true" \
      name="cgal-toolbox" \
      usage="This image is meant to be used with the toolbox command"
