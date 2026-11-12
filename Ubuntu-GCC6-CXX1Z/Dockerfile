ARG base_image=cgal/testsuite-docker:ubuntu-gcc6
FROM ${base_image} AS cgal-common

ENV CGAL_TEST_PLATFORM="Ubuntu-latest-GCC6-CXX1z"
ENV CGAL_SUMMARY_NAME="Ubuntu-latest-GCC_master-CXX1z"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DDONT_USE_BOOST_PROGRAM_OPTIONS -Wall -Wextra -std=c++1z\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

FROM cgal-common AS cgal-base
ARG dockerfile_url
ARG image_tag
ENV DOCKERFILE_URL=$dockerfile_url
ENV IMAGE_TAG=$image_tag

FROM cgal-common AS cgal-toolbox
ARG dockerfile_url
ARG image_tag
ENV DOCKERFILE_URL=$dockerfile_url
ENV IMAGE_TAG=$image_tag

LABEL com.github.containers.toolbox="true" \
      name="cgal-toolbox" \
      usage="This image is meant to be used with the toolbox command"

COPY --from=root Ubuntu/toolbox-setup.sh /tmp/toolbox-setup.sh
RUN sh /tmp/toolbox-setup.sh && rm /tmp/toolbox-setup.sh
