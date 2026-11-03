FROM fedora:rawhide as cgal-base
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url
ARG image_tag
ENV IMAGE_TAG=$image_tag

RUN dnf -y upgrade && \
    [ -x /usr/bin/dnf ] || ln -s /usr/bin/dnf5 /usr/bin/dnf && \
    dnf -y install --refresh make cmake gcc-c++ \
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
		   diffutils \
                   wget \
                   git \
                   lsb-release \
                   json-devel \
                   tar && \
    dnf clean all && \
    wget https://github.com/oneapi-src/oneTBB/archive/refs/tags/v2022.0.0.tar.gz && \
    tar xf v2022.0.0.tar.gz && \
    mkdir build && \
    cd build && \
    sed -i '1i #include <cstdlib>' /oneTBB-2022.0.0/test/common/utils_assert.h && \
    cmake -DCMAKE_BUILD_TYPE=Release -DTBB_STRICT:BOOL=OFF -DTBB_TEST:BOOL=OFF ../oneTBB-2022.0.0 && \
    make && \
    make install && \
    cd .. && rm -rf v2022.0.0.tar.gz oneTBB-2022.0.0 build

ENV CGAL_TEST_PLATFORM="Fedora-rawhide"
ENV CGAL_SUMMARY_NAME="Fedora-testing-Debug"
ENV CGAL_CMAKE_FLAGS="('-DCGAL_HEADER_ONLY:BOOL=TRUE')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

# ===== STAGE 2: Toolbox Variant =====
# Derived from cgal-base with toolbox-specific configurations
FROM cgal-base as cgal-toolbox

LABEL com.github.containers.toolbox="true" \
      name="cgal-toolbox" \
      usage="This image is meant to be used with the toolbox command"

# Remove container-specific configurations that conflict with toolbox
RUN rm -f /etc/containers/mounts.conf /etc/containers/containers.conf /etc/containers/registries.conf /etc/containers/storage.conf

# Configure hostname resolution for toolbox compatibility
RUN grep -Eq '^hosts:.*[[:space:]]myhostname([[:space:]]|$)' /etc/nsswitch.conf || sed -Ei 's/^(hosts:.*\<files\>)/\1 myhostname/' /etc/nsswitch.conf

# Create required directories for toolbox
RUN mkdir -p /usr/share/empty /etc/pkcs11/modules /etc/krb5.conf.d

# Install sudo and zsh for toolbox environment
RUN dnf install -y sudo zsh && dnf clean all

# Allow the Toolbx user to use sudo without a password
RUN printf '%s\n' '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-toolbox && chmod 0440 /etc/sudoers.d/99-toolbox
