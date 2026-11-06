ARG base_image=cgal/testsuite-docker:debian-testing
FROM ${base_image} AS cgal-base
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN apt-get update -y && apt-get install -y wget \
&& wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc \
&& echo 'deb http://apt.llvm.org/unstable/ llvm-toolchain main' > /etc/apt/sources.list.d/llvm.list \
&& apt-get update -y \
&& apt-get install -y clang-22 \
&& apt-get clean all

ENV CXX=/usr/bin/clang++-22
ENV CC=/usr/bin/clang-22
ENV CGAL_TEST_PLATFORM="Debian-testing-clang-main"
ENV CGAL_SUMMARY_NAME="Debian-testing-clang-main"
ENV CGAL_WITH_FASTFLOAT="ON"

# ===== STAGE 2: Toolbox Variant =====
# Derived from cgal-base with toolbox-specific configurations
FROM cgal-base AS cgal-toolbox

LABEL com.github.containers.toolbox="true" \
      name="cgal-toolbox" \
      usage="This image is meant to be used with the toolbox command"

# Remove container-specific optimizations that conflict with toolbox
RUN rm -f /etc/apt/apt.conf.d/docker-*

# Configure hostname resolution for toolbox compatibility
RUN grep -Eq '^hosts:.*[[:space:]]myhostname([[:space:]]|$)' /etc/nsswitch.conf || sed -Ei 's/^(hosts:.*\<files\>)/\1 myhostname/' /etc/nsswitch.conf

# Install libnss-myhostname for proper hostname resolution
RUN apt-get update && apt-get install -y libnss-myhostname && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create required directories for toolbox
RUN mkdir -p /usr/share/empty /etc/pkcs11/modules /etc/krb5.conf.d

# Install toolbox tools and enable passwordless sudo for the sudo group
RUN apt-get update && apt-get install -y sudo zsh libcap2-bin && \
    printf '%s\n' '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-toolbox && \
    chmod 0440 /etc/sudoers.d/99-toolbox && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
