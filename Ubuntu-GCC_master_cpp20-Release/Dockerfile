FROM cgal/testsuite-docker:ubuntu-gcc6
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="Ubuntu-GCC_master_CXX20-Release"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DDONT_USE_BOOST_PROGRAM_OPTIONS -Wall -Wextra -std=c++2a -O3 -DCGAL_NDEBUG\" \"-DWITH_CGAL_Qt3:BOOL=OFF\" \"-DCMAKE_PREFIX_PATH=/usr/local/boost\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

RUN git clone -b develop --depth=1 --shallow-submodules --recursive https://github.com/boostorg/boost.git && \
        cd boost && git submodule update -q && \
        ./bootstrap.sh --prefix=/usr/local/boost --with-libraries=container,filesystem,system,serialization,iostreams,program_options,thread,date_time && \
        ./b2 -d0 install -j4 && \
        cd .. && rm -rf boost

RUN git clone --depth=1 --shallow-submodules  https://gitlab.com/libeigen/eigen.git && \
        cd eigen && git submodule update --quiet --init --recursive && \
        mkdir build && cd build && \
        cmake .. && make install && cd .. && rm -rf eigen
        
LABEL org.cgal.releases_to_ignore="^(4|5\\.0)"
