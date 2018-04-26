FROM cgal/testsuite-docker:ubuntu
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    liblapack-dev \
    libopenblas-dev \
    openmpi-bin \
    libopenmpi-dev \
    && apt-get clean

RUN buildDeps='bison flex libmpc-dev g++ ' \
 && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
 && git clone git://github.com/gcc-mirror/gcc.git --depth 1 \
 && cd gcc \
 && mkdir objdir \
 && cd objdir \
 && ../configure --enable-languages=c,c++ --disable-multilib \
    --disable-bootstrap --build=x86_64-linux-gnu \
 && make -j"$(nproc)" \
 && make install \
 && make distclean \
 && cd ../.. \
 && rm -rf ./gcc \
 && sed -i '1s/^/\/usr\/local\/lib64\n/' /etc/ld.so.conf \
 && ldconfig \
 && apt-get purge -y --auto-remove $buildDeps

ENV CGAL_TEST_PLATFORM="Ubuntu-latest-GCC6"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DDONT_USE_BOOST_PROGRAM_OPTIONS -Wall -Wno-expansion-to-defined\" \"-DWITH_CGAL_Qt3:BOOL=OFF\")"

