FROM cgal/testsuite-docker:fedora
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="Fedora-Release"
ENV CGAL_CMAKE_FLAGS="('-DCMAKE_BUILD_TYPE=Release' '-DCMAKE_CXX_FLAGS_RELEASE=-msse3 -O3 -DCGAL_NDEBUG' '-DWITH_GMPXX=ON')"
ENV CGAL_USE_ASAN=1
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
