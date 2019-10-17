FROM cgal/testsuite-docker:ubuntu

MAINTAINER Maxime Gimeno

#install the necessary packages
RUN apt-get update \
 && apt-get install -y python \
 && apt-get install -y subversion \
 && apt-get install unzip \
 && apt-get install wget \
 && apt-get clean -y \
 && cd /tmp \
 && svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm \
 && cd ./llvm/tools \
 && svn co http://llvm.org/svn/llvm-project/cfe/trunk clang \
 && cd /tmp && mkdir build \
 && cd ./build \
 && cmake -DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/g++ ../llvm -DCMAKE_BUILD_TYPE=Release \
 && make -j"$(nproc)" \
 && make -j"$(nproc)" install \
 && cd /tmp && rm -rf build llvm \
 && wget "https://github.com/CGAL/LAStools/archive/master.zip" -O laslib.zip \
 && unzip laslib.zip \
 && cd ./LAStools-master \
 && cmake -DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/g++ -DCMAKE_CXX_FLAGS=-std=c++11 . \
 && make -j "$(nproc)" \
 && make install \
 && cd .. \
 && rm -rf LAStools-master \
 && rm -rf laslib.zip

ENV CGAL_TEST_PLATFORM="Ubuntu-clang-latest"
ENV CXX=/usr/local/bin/clang++
ENV CC=/usr/local/bin/clang
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DDONT_USE_BOOST_PROGRAM_OPTIONS -Wthread-safety\")"

ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
