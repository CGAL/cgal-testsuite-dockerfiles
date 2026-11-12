# The common stage is shared by the standard and toolbox variants.
# Build with: docker build --target cgal-base (or --target cgal-toolbox).

ARG base_image=cgal/testsuite-docker:ubuntu
FROM ${base_image} AS cgal-common

ENV CGAL_TEST_PLATFORM="Ubuntu-no-gmp-no-leda"
ENV CGAL_SUMMARY_NAME="Ubuntu-latest-no-gmp-no-leda"
ENV INIT_FILE=/init.cmake
COPY ./init.cmake .

# Install Cuda 12.8. and libProtoSphere for Sphere_packing
COPY fix-cuda-glibc-noexcept.sh /tmp/
RUN sed -i 's/\r$//' /tmp/fix-cuda-glibc-noexcept.sh \
 && wget --progress=dot:giga https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin \
 && mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600  \
 && apt-get update && apt-get -y install --no-install-recommends gcc-14 g++-14 \
 && wget --progress=dot:giga https://developer.download.nvidia.com/compute/cuda/12.8.2/local_installers/cuda-repo-ubuntu2404-12-8-local_12.8.2-570.211.01-1_amd64.deb \
 && dpkg -i cuda-repo-ubuntu2404-12-8-local_12.8.2-570.211.01-1_amd64.deb && rm ./*.deb \
 && cp /var/cuda-repo-ubuntu2404-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/ \
 && apt-get update \
 && apt-get -y install --no-install-recommends cuda-nvcc-12-8 cuda-nvrtc-dev-12-8 cuda-opencl-dev-12-8 \
 && apt-get remove -y --purge "cuda-repo-ubuntu2404-12-8-local*" \
 && sh /tmp/fix-cuda-glibc-noexcept.sh /usr/local/cuda \
 && printf '#include <cmath>\n#include <math.h>\n__global__ void k(double* p, float* q) { p[0] = sinpi(p[0]) + cospi(p[0]) + rsqrt(p[0]); q[0] = sinpif(q[0]) + cospif(q[0]) + rsqrtf(q[0]); }\n' > /tmp/t.cu \
 && /usr/local/cuda/bin/nvcc -ccbin g++-14 -c /tmp/t.cu -o /tmp/t.o \
 && rm -f /tmp/t.cu /tmp/t.o /tmp/fix-cuda-glibc-noexcept.sh \
 && cd /home  \
 && git clone https://github.com/NVIDIA/cuda-samples.git \
 && git clone -b test_cgal https://gitlab.informatik.uni-bremen.de/cgvr_public/protosphereextended.git \
 && cd protosphereextended \
 && mkdir build \
 && cd build/ \
 && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=gcc-14 -DCMAKE_CXX_COMPILER=g++-14 -DCMAKE_CUDA_HOST_COMPILER=/usr/bin/g++-14 -DCUDA_EXAMPLE_INCLUDE_DIR=/home/cuda-samples/Common .. \
 && make -j "$(nproc)" \
 && make install \
 && cd /home \
 && rm -rf protosphereextended cuda-samples

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
