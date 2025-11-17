FROM cgal/testsuite-docker:ubuntu

ARG dockerfile_url
ARG image_tag
ENV DOCKERFILE_URL=$dockerfile_url
ENV IMAGE_TAG=$image_tag

ENV CGAL_TEST_PLATFORM="Ubuntu-no-gmp-no-leda"
ENV CGAL_SUMMARY_NAME="Ubuntu-latest-no-gmp-no-leda"
ENV INIT_FILE=/init.cmake
COPY ./init.cmake .

