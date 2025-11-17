FROM cgal/testsuite-docker:fedora
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url
ARG image_tag
ENV IMAGE_TAG=$image_tag

RUN dnf -y install libasan && dnf clean all

ENV CGAL_TEST_PLATFORM="Fedora-Release"
ENV CGAL_SUMMARY_NAME="Fedora-latest-Release-ASAN"
ENV CGAL_CMAKE_FLAGS="('-DCMAKE_BUILD_TYPE=Release' '-DCMAKE_CXX_FLAGS_RELEASE=-msse3 -O3 -DCGAL_NDEBUG -fsanitize=address' '-DWITH_GMPXX=ON')"
ENV CGAL_USE_ASAN=1
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
