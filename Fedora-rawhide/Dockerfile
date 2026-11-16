FROM fedora:rawhide AS cgal-common

RUN dnf -y upgrade --refresh && \
    dnf -y install --setopt=install_weak_deps=False make cmake gcc-c++ \
                   gawk util-linux \
                   gmp-devel.x86_64 mpfr-devel.x86_64 \
                   boost-devel.x86_64 \
                   ntl-devel.x86_64 \
                   ipe-devel.x86_64 \
                   eigen3-devel.noarch \
                   qt5-qtbase-devel.x86_64 \
                   qt5-qtscript-devel.x86_64 \
                   qt5-qtsvg-devel.x86_64 \
                   qt5-qttools-devel.x86_64 \
                   qt6-qtbase-devel.x86_64 \
                   qt6-qtsvg-devel.x86_64 \
                   qt6-qttools-devel.x86_64 \
                   mesa-libGLU-devel \
                   OpenMesh-devel \
                   'zlib-devel(x86-64)' \
                   'zlib-static(x86-64)' \
                   'libpng-static(x86-64)' \
                   diffutils \
                   wget \
                   git \
                   lsb-release \
                   json-devel \
                   tar && \
    dnf clean all && \
    wget --progress=dot:giga https://github.com/oneapi-src/oneTBB/archive/refs/tags/v2022.0.0.tar.gz && \
    tar xf v2022.0.0.tar.gz && \
    sed -i '1i #include <cstdlib>' /oneTBB-2022.0.0/test/common/utils_assert.h && \
    cmake -S /oneTBB-2022.0.0 -B /build -DCMAKE_BUILD_TYPE=Release -DTBB_STRICT:BOOL=OFF -DTBB_TEST:BOOL=OFF && \
    cmake --build /build --parallel "$(nproc)" && \
    cmake --install /build && \
    rm -rf /v2022.0.0.tar.gz /oneTBB-2022.0.0 /build

ENV CGAL_TEST_PLATFORM="Fedora-rawhide"
ENV CGAL_SUMMARY_NAME="Fedora-testing-Debug"
ENV CGAL_CMAKE_FLAGS="('-DCGAL_HEADER_ONLY:BOOL=TRUE')"
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
