ARG base_image=cgal/testsuite-docker:debian-stable
FROM ${base_image} AS cgal-common

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf \
    ssh \
    python3 \
    gzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV CGAL_TEST_PLATFORM="Debian-stable-cross-compilation-for-arm"
COPY ./startup.sh /startup.sh
CMD ["bash", "/startup.sh"]

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

COPY --from=root Debian-stable/toolbox-setup.sh /tmp/toolbox-setup.sh
RUN sh /tmp/toolbox-setup.sh && rm /tmp/toolbox-setup.sh
