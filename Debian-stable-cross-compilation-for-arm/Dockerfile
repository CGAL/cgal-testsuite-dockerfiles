FROM cgal/testsuite-docker:debian-stable AS cgal-base
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url
ARG image_tag
ENV IMAGE_TAG=$image_tag

RUN apt-get update && apt-get install -y \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf \
    ssh \
    python3 \
    gzip

ENV CGAL_TEST_PLATFORM="Debian-stable-cross-compilation-for-arm"
COPY ./startup.sh .
CMD bash ./startup.sh

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
RUN apt-get update && apt-get install -y sudo zsh && \
    printf '%s\n' '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-toolbox && \
    chmod 0440 /etc/sudoers.d/99-toolbox && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
