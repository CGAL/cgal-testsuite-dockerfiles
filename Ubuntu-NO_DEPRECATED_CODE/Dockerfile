FROM cgal/testsuite-docker:ubuntu
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="Ubuntu-Latest-NO_DEPRECATED_CODE"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DCGAL_NO_DEPRECATED_CODE\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
