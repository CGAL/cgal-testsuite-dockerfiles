FROM fedora:latest AS cgal-common

RUN dnf -y upgrade --refresh && \
  dnf -y install --setopt=install_weak_deps=False \
    boost-devel.x86_64 \
    awk \
    patch \
    cmake \
    eigen3-devel.noarch \
    gcc-c++ \
    glew-devel.x86_64 \
    gmp-devel.x86_64 \
    ipe-devel.x86_64 \
    OpenMesh-devel \
    opencv-devel \
    make \
    mpfr-devel.x86_64 \
    mpfi-devel.x86_64 \
    ntl-devel.x86_64 \
    qt5-qtbase-devel.x86_64 \
    qt5-qtscript-devel.x86_64 \
    qt5-qtsvg-devel.x86_64 \
    qt5-qttools-devel.x86_64 \
    qt6-qtbase-devel.x86_64 \
    qt6-qtsvg-devel.x86_64 \
    qt6-qttools-devel.x86_64 \
    qt6-qtwebsockets-devel.x86_64 \
    qt6-qtdeclarative-devel.x86_64 \
    tar \
    unzip \
    wget \
    tbb-devel \
    'zlib-devel(x86-64)' \
    'zlib-static(x86-64)' \
    'libpng-static(x86-64)' \
    diffutils.x86_64 \
    git \
    libssh-devel \
    lsb-release \
    json-devel \
    InsightToolkit-devel gdcm-devel libminc-devel vxl-devel \
    fast_float-devel && \
  dnf clean all

# Copy and run the script to install LAStools
COPY --from=root install_lastools.sh LAStools.patch /tmp/
RUN bash /tmp/install_lastools.sh

ENV CGAL_TEST_PLATFORM="Fedora"
ENV CGAL_SUMMARY_NAME="Fedora-latest-Debug"
ENV CGAL_CMAKE_FLAGS=""
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

COPY --from=root Fedora/toolbox-setup.sh /tmp/toolbox-setup.sh
RUN sh /tmp/toolbox-setup.sh && rm /tmp/toolbox-setup.sh
