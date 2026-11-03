FROM fedora:latest AS cgal-base
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN dnf -y update; dnf clean all
RUN dnf -y install \
    awk util-linux \
    boost-devel.i686 \
    cmake \
    eigen3-devel.noarch \
    libatomic.i686 \
    gcc-c++.i686 \
    gcc-c++.x86_64 \
    glew-devel.i686 \
    glibc-devel.i686 \
    gmp-devel.i686 \
    libstdc++-devel.i686 \
    libstdc++-devel.x86_64 \
    make \
    mesa-libGL-devel.i686 \
    mesa-libGLU-devel.i686 \
    mpfr-devel.i686 \
    tar \
    tbb-devel.i686 \
    diffutils \
    git \
    lsb-release \
    json-devel \
    'zlib-static(x86-32)' \
    'zlib-devel(x86-32)' && dnf clean all

RUN  git clone https://github.com/fastfloat/fast_float \
 &&  cd fast_float \
 &&  git checkout v8.3.3 \
 &&  mkdir build \
 &&  cd build \
 &&  cmake .. \
 &&  make install \
 && cd .. && rm -rf fast_float

ENV CC="gcc -m32" CXX="g++ -m32"
ENV CGAL_TEST_PLATFORM="Fedora-32"
ENV CGAL_SUMMARY_NAME="Fedora-latest-32-Debug"
ENV CGAL_CMAKE_FLAGS="('-DCGAL_HEADER_ONLY:BOOL=TRUE')"
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
RUN dnf install -y sudo zsh && dnf clean all

# Allow the Toolbx user to use sudo without a password
RUN printf '%s\n' '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-toolbox && chmod 0440 /etc/sudoers.d/99-toolbox
