FROM cgal/testsuite-docker:archlinux-clang
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="ArchLinux-clang-CXX14"
ENV CGAL_CMAKE_FLAGS="(\"-DCMAKE_CXX_FLAGS_DEBUG="" \" \"-DCMAKE_C_COMPILER:FILEPATH=/bin/clang\" \"-DCMAKE_CXX_COMPILER:FILEPATH=/bin/clang++\" \"-DCGAL_CXX_FLAGS=-Wall -std=c++14\")" CXX=/bin/clang++ CC=/bin/clang
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
