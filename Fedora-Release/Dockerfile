ARG base_image=cgal/testsuite-docker:fedora
FROM ${base_image} AS cgal-common

RUN dnf -y install --setopt=install_weak_deps=False libasan && dnf clean all

ENV CGAL_TEST_PLATFORM="Fedora-Release"
ENV CGAL_SUMMARY_NAME="Fedora-latest-Release-ASAN"
ENV CGAL_CMAKE_FLAGS="('-DCMAKE_BUILD_TYPE=Release' '-DCMAKE_CXX_FLAGS_RELEASE=-msse3 -O3 -DCGAL_NDEBUG -fsanitize=address' '-DWITH_GMPXX=ON')"
ENV CGAL_USE_ASAN=1
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

COPY --from=root Fedora/toolbox-setup.sh /tmp/toolbox-setup.sh
RUN sh /tmp/toolbox-setup.sh && rm /tmp/toolbox-setup.sh
