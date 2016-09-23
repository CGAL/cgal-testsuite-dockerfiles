FROM cgal/testsuite-docker:ubuntu

MAINTAINER Maxime Gimeno

#install the necessary packages
RUN apt-get update \
 && apt-get install -y python \
 && apt-get install -y subversion 

#download llvm and clang from trunk
RUN cd /tmp \
 && svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm \
 && cd ./llvm/tools \
 && svn co http://llvm.org/svn/llvm-project/cfe/trunk clang 

#build llvm and clang
RUN cd  /tmp/ \
 && mkdir build \
 && cd ./build \
 && cmake -DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/g++ ../llvm \
 && make -j"$(nproc)"

#Clean-up and set some ENV variables
RUN cd /tmp \
 && rm -rf ./llvm
ENV PATH="/tmp/build/bin:${PATH}"
ENV CGAL_TEST_PLATFORM="Ubuntu-clang-latest"
ENV CC=/tmp/build/bin/clang
ENV CXX=/tmp/build/bin/clang++
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DDONT_USE_BOOST_PROGRAM_OPTIONS -Wthread-safety\" \"-DWITH_CGAL_Qt3:BOOL=OFF\" \"-DCMAKE_C_COMPILER:FILEPATH=/tmp/build/bin/clang\" \"-DCMAKE_CXX_COMPILER:FILEPATH=/tmp/build/bin/clang++ \")"
