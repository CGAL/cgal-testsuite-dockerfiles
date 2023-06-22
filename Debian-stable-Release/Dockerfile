FROM cgal/testsuite-docker:debian-stable
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="Debian-stable-Release"
ENV CGAL_CMAKE_FLAGS="('-DCMAKE_BUILD_TYPE=Release' '-DCMAKE_CXX_FLAGS_RELEASE=-O3 -DCGAL_NDEBUG')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
