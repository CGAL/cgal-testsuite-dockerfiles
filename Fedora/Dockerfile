FROM fedora:latest AS cgal-base
ARG dockerfile_url
ARG image_tag
ENV DOCKERFILE_URL=$dockerfile_url
ENV IMAGE_TAG=$image_tag

RUN dnf -y update; dnf clean all
RUN dnf -y install \
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
    'libpng-static(x86-64)' \
    diffutils.x86_64 \
    git \
    libssh-devel \
    lsb-release \
    json-devel \
    InsightToolkit-devel gdcm-devel libminc-devel vxl-devel \
    fast_float-devel

#    'zlib-devel(x86-64)' \
#    'zlib-static(x86-64)' \

# Copy and run the script to install LAStools
COPY --from=root install_lastools.sh LAStools.patch /tmp/
RUN chmod +x /tmp/install_lastools.sh && bash /tmp/install_lastools.sh

ENV CGAL_TEST_PLATFORM="Fedora"
ENV CGAL_SUMMARY_NAME="Fedora-latest-Debug"
ENV CGAL_CMAKE_FLAGS=""
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

# ===== STAGE 2: Toolbox Variant =====
# Derived from cgal-base with toolbox-specific configurations
FROM cgal-base AS cgal-toolbox

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
RUN dnf install -y sudo zsh flatpak-xdg-utils p11-kit-client vte-profile && dnf clean all

# Allow the Toolbx user to use sudo without a password
RUN printf '%s\n' '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-toolbox && chmod 0440 /etc/sudoers.d/99-toolbox
