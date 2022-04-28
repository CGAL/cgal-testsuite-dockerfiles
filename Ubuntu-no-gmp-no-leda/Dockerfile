FROM cgal/testsuite-docker:ubuntu

ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="Ubuntu-no-gmp-no-leda"
ENV INIT_FILE=/init.cmake
COPY ./init.cmake .

