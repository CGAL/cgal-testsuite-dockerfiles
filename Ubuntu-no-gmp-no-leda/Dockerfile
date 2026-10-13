FROM cgal/testsuite-docker:ubuntu

ARG dockerfile_url
ARG image_tag
ENV DOCKERFILE_URL=$dockerfile_url
ENV IMAGE_TAG=$image_tag

ENV CGAL_TEST_PLATFORM="Ubuntu-no-gmp-no-leda"
ENV CGAL_SUMMARY_NAME="Ubuntu-latest-no-gmp-no-leda"
ENV INIT_FILE=/init.cmake
COPY ./init.cmake .

# Install Cuda 12.8. and libProtoSphere for Sphere_packing
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin \
 && mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600  \
 && wget https://developer.download.nvidia.com/compute/cuda/12.8.2/local_installers/cuda-repo-ubuntu2404-12-8-local_12.8.2-570.211.01-1_amd64.deb \
 && dpkg -i cuda-repo-ubuntu2404-12-8-local_12.8.2-570.211.01-1_amd64.deb \
 && cp /var/cuda-repo-ubuntu2404-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/ \
 && apt-get update \
 && apt-get -y install cuda-toolkit-12-8 \
 && cd /home  \
 && git clone https://github.com/NVIDIA/cuda-samples.git \
 && git clone -b test_cgal https://gitlab.informatik.uni-bremen.de/cgvr_public/protosphereextended.git \
 && cd protosphereextended \
 && mkdir build \
 && cd build/ \
 && cmake -DCMAKE_BUILD_TYPE=Release -DCUDA_EXAMPLE_INCLUDE_DIR=/home/cuda-samples/Common .. \
 && make -j "$(nproc)" \
 && make install \
 