FROM cgal/testsuite-docker:fedora

ARG dockerfile_url

#install the necessary packages
RUN dnf -y update; dnf clean all

RUN dnf -y install \
    python \
    subversion \
 && yum clean all -y \
 && cd /tmp \
 && svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm \
 && cd ./llvm/tools \
 && svn co http://llvm.org/svn/llvm-project/cfe/trunk clang \
 && cd /tmp && mkdir build \
 && cd ./build \
 && cmake -DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/g++ ../llvm -DCMAKE_BUILD_TYPE=Release \
 && make -j"$(nproc)" \
 && make -j"$(nproc)" install \
 && cd /tmp && rm -rf build llvm 
ENV CGAL_TEST_PLATFORM="Fedora-clang-latest"
ENV CXX=/usr/local/bin/clang++
ENV CC=/usr/local/bin/clang
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DDONT_USE_BOOST_PROGRAM_OPTIONS -Wthread-safety\")"

ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
