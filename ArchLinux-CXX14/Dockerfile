FROM cgal/testsuite-docker:archlinux
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="ArchLinux-CXX14"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\" \"-DCMAKE_POLICY_DEFAULT_CMP0053=OLD\" \"-DCGAL_HEADER_ONLY=OFF\" \"-DLEDA_INCLUDE_DIR=/usr/include/LEDA\" \"-DCGAL_CXX_FLAGS=-Wall -std=gnu++14\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
