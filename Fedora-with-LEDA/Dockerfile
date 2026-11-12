ARG base_image=cgal/testsuite-docker:fedora
FROM ${base_image} AS cgal-common

ENV CGAL_TEST_PLATFORM="Fedora-with-LEDA"
ENV CGAL_SUMMARY_NAME="Fedora-latest-With-LEDA"
ENV LEDA_DIR="/mnt/testresults/leda-numbers/" LD_LIBRARY_PATH=/mnt/testresults/leda-numbers/
ENV INIT_FILE=/tmp/init.cmake
ENV CGAL_DISABLE_GMP=ON
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

COPY --from=root Fedora/toolbox-setup.sh /tmp/toolbox-setup.sh
RUN sh /tmp/toolbox-setup.sh && rm /tmp/toolbox-setup.sh
