# This Dockerfile builds on a base variant.
# Build with: docker build --target cgal-base (or --target cgal-toolbox)
# See the base variant Dockerfile for multi-stage definitions.

ARG base_image=cgal/testsuite-docker:archlinux-clang
FROM ${base_image}
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="ArchLinux-clang-CXX20-Release"
ENV CGAL_SUMMARY_NAME="ArchLinux-basedevel-clang-CXX20"
ENV CGAL_CMAKE_FLAGS="(\"-DCMAKE_CXX_FLAGS_DEBUG="" \" \"-DCMAKE_C_COMPILER:FILEPATH=/bin/clang\" \"-DCMAKE_CXX_COMPILER:FILEPATH=/bin/clang++\" \"-DCMAKE_CXX_FLAGS=-Wall -O3 -std=c++20\" \"-DCMAKE_PREFIX_PATH=/usr/local/boost\")" CXX=/bin/clang++ CC=/bin/clang
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

RUN git clone -b develop --depth=1 --shallow-submodules --recursive https://github.com/boostorg/boost.git && \
        cd boost && git submodule update && \
        ./bootstrap.sh --with-toolset=clang --prefix=/usr/local/boost --with-libraries=container,filesystem,serialization,iostreams,program_options,thread && \
        ./b2 -d0 install -j4 && \
        cd .. && rm -rf boost

LABEL org.cgal.releases_to_ignore="^(4|5\\.0)"
