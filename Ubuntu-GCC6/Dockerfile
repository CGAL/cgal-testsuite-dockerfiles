FROM cgal/testsuite-docker:ubuntu as cgal-base
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

# ===== STAGE 2: Toolbox Variant =====
# Derived from cgal-base with toolbox-specific configurations
FROM cgal-base as cgal-toolbox

LABEL com.github.containers.toolbox="true" \
      name="cgal-toolbox" \
      usage="This image is meant to be used with the toolbox command"

# Remove container-specific optimizations that conflict with toolbox
RUN rm -f /etc/apt/apt.conf.d/docker-*

# Remove the base image's UID 1000 user so Toolbx can create the host user.
RUN userdel --remove ubuntu && if getent group ubuntu >/dev/null; then groupdel ubuntu; fi

# Configure hostname resolution for toolbox compatibility
RUN grep -Eq '^hosts:.*[[:space:]]myhostname([[:space:]]|$)' /etc/nsswitch.conf || sed -Ei 's/^(hosts:.*\<files\>)/\1 myhostname/' /etc/nsswitch.conf

# Install libnss-myhostname for proper hostname resolution
RUN apt-get update && apt-get install -y libnss-myhostname && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create required directories for toolbox
RUN mkdir -p /usr/share/empty /etc/pkcs11/modules /etc/krb5.conf.d

# Install toolbox tools and enable passwordless sudo for the sudo group
RUN apt-get update && apt-get install -y sudo zsh && \
    printf '%s\n' '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-toolbox && \
    chmod 0440 /etc/sudoers.d/99-toolbox && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
