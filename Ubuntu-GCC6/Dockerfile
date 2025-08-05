FROM cgal/testsuite-docker:ubuntu
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN apt-get update && apt-get install -y \
    build-essential \
    liblapack-dev \
    libopenblas-dev \
    openmpi-bin \
    libopenmpi-dev \
    && apt-get clean

RUN buildDeps='bison flex libmpc-dev g++ ' \
 && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
 && git clone https://github.com/gcc-mirror/gcc.git --depth 1 \
 && cd gcc \
 && mkdir objdir \
 && cd objdir \
 && ../configure --enable-languages=c,c++ --disable-multilib \
    --disable-bootstrap --build=x86_64-linux-gnu \
 && make -j"$(nproc)" \
 && make install \
  && cd ../.. \
 && rm -rf ./gcc \
 && sed -i '1s/^/\/usr\/local\/lib64\n/' /etc/ld.so.conf \
 && ldconfig \
 && apt-get purge -y --auto-remove $buildDeps

RUN git clone -b develop --depth=1 --shallow-submodules --recursive https://github.com/boostorg/boost.git && \
        cd boost && git submodule update -q && \
        ./bootstrap.sh --prefix=/usr/local/boost --with-libraries=container,serialization,iostreams,program_options,thread,date_time,chrono && \
        ./b2 -d0 install -j4 && \
        cd .. && rm -rf boost

RUN git clone --depth=1 --shallow-submodules  https://gitlab.com/libeigen/eigen.git && \
        cd eigen && git submodule update --quiet --init --recursive && \
        mkdir build && cd build && \
        cmake .. && make install && cd .. && rm -rf eigen

ENV CGAL_TEST_PLATFORM="Ubuntu-latest-GCC6"
ENV CGAL_SUMMARY_NAME="Ubuntu-latest-GCC_master-Debug"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DDONT_USE_BOOST_PROGRAM_OPTIONS -Wall -Wno-expansion-to-defined\")"

ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
