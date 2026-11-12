ARG base_image=cgal/testsuite-docker:debian-testing
FROM ${base_image} AS cgal-common

RUN apt-get update -y && apt-get install -y wget \
&& wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc \
&& echo 'deb http://apt.llvm.org/unstable/ llvm-toolchain main' > /etc/apt/sources.list.d/llvm.list \
&& apt-get update -y \
&& apt-get install -y clang-22 \
&& apt-get clean all

ENV CXX=/usr/bin/clang++-22
ENV CC=/usr/bin/clang-22
ENV CGAL_TEST_PLATFORM="Debian-testing-clang-main"
ENV CGAL_SUMMARY_NAME="Debian-testing-clang-main"
ENV CGAL_WITH_FASTFLOAT="ON"

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
RUN sh /tmp/toolbox-setup.sh libcap2-bin && rm /tmp/toolbox-setup.sh
