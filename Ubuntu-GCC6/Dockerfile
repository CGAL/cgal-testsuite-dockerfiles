ARG base_image=cgal/testsuite-docker:ubuntu
FROM ${base_image} AS cgal-common

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    liblapack-dev \
    libopenblas-dev \
    openmpi-bin \
    libopenmpi-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends bison flex libmpc-dev g++ \
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
 && apt-get purge -y --auto-remove bison flex libmpc-dev g++ \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone -b develop --depth=1 --shallow-submodules --recursive https://github.com/boostorg/boost.git && \
        cd boost && git submodule update -q && \
        ./bootstrap.sh --prefix=/usr/local/boost --with-libraries=container,serialization,iostreams,program_options,thread,date_time,chrono && \
        ./b2 -d0 install -j4 && \
        cd .. && rm -rf boost

RUN git clone --depth=1 --shallow-submodules  https://gitlab.com/libeigen/eigen.git && \
        git -C /eigen submodule update --quiet --init --recursive && \
        cmake -S /eigen -B /eigen/build && \
        cmake --build /eigen/build --parallel "$(nproc)" && \
        cmake --install /eigen/build && \
        rm -rf /eigen

ENV CGAL_TEST_PLATFORM="Ubuntu-latest-GCC6"
ENV CGAL_SUMMARY_NAME="Ubuntu-latest-GCC_master-Debug"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DDONT_USE_BOOST_PROGRAM_OPTIONS -Wall -Wno-expansion-to-defined\")"

ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

FROM cgal-common AS cgal-base
ARG dockerfile_url
ARG image_tag
ENV DOCKERFILE_URL=$dockerfile_url
ENV IMAGE_TAG=$image_tag

FROM cgal-common AS cgal-toolbox
ARG dockerfile_url
ARG image_tag
ENV DOCKERFILE_URL=$dockerfile_url
ENV IMAGE_TAG=$image_tag

LABEL com.github.containers.toolbox="true" \
      name="cgal-toolbox" \
      usage="This image is meant to be used with the toolbox command"

COPY --from=root Ubuntu/toolbox-setup.sh /tmp/toolbox-setup.sh
RUN sh /tmp/toolbox-setup.sh && rm /tmp/toolbox-setup.sh
