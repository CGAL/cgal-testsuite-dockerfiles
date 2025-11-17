FROM cgal/testsuite-docker:ubuntu

ARG dockerfile_url
ARG image_tag
ENV DOCKERFILE_URL=$dockerfile_url
ENV IMAGE_TAG=$image_tag

#install the necessary packages
RUN apt-get update \
 && apt-get install -y python subversion patch unzip wget \
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
 && cd /tmp && rm -rf build llvm

# Copy and run the script to install LAStools
COPY --from=root install_lastools.sh LAStools.patch /tmp/
RUN chmod +x /tmp/install_lastools.sh && bash /tmp/install_lastools.sh

ENV CGAL_TEST_PLATFORM="Ubuntu-clang-latest"
ENV CXX=/usr/local/bin/clang++
ENV CC=/usr/local/bin/clang
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DDONT_USE_BOOST_PROGRAM_OPTIONS -Wthread-safety\")"

ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
