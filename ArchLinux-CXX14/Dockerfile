ARG base_image=cgal/testsuite-docker:archlinux
FROM ${base_image} AS cgal-common

ENV CGAL_TEST_PLATFORM="ArchLinux-CXX14"
ENV CGAL_SUMMARY_NAME="ArchLinux-basedevel-CXX14"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_HEADER_ONLY=OFF\" \"-DCGAL_CXX_FLAGS=-Wall -std=gnu++14\")"
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

COPY --from=root ArchLinux/toolbox-setup.sh /tmp/toolbox-setup.sh
RUN sh /tmp/toolbox-setup.sh && rm /tmp/toolbox-setup.sh
