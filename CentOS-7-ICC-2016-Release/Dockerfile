FROM cgal/testsuite-docker:centos7-icc-2016
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="CentOS7-ICC-2016-Release"
ENV CGAL_CMAKE_FLAGS="('-DCMAKE_BUILD_TYPE=Release' '-DCMAKE_CXX_FLAGS_RELEASE=-w1 -O3 -DCGAL_NDEBUG')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
