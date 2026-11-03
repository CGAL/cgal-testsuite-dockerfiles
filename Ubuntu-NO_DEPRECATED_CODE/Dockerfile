FROM cgal/testsuite-docker:ubuntu as cgal-base
ARG dockerfile_url
ARG image_tag
ENV DOCKERFILE_URL=$dockerfile_url
ENV IMAGE_TAG=$image_tag

#add qt6 as it is not run on cgal.gf.com
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libgl-dev \
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-svg-dev \
    qt6-websockets-dev

ENV CGAL_TEST_PLATFORM="Ubuntu-Latest-NO_DEPRECATED_CODE"
ENV CGAL_SUMMARY_NAME="Ubuntu-latest-NO_DEPRECATED_CODE"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DCGAL_NO_DEPRECATED_CODE\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

# ===== STAGE 2: Toolbox Variant =====
# Derived from cgal-base with toolbox-specific configurations
FROM cgal-base as cgal-toolbox

LABEL com.github.containers.toolbox="true" \
      name="cgal-toolbox" \
      usage="This image is meant to be used with the toolbox command"

# Remove container-specific optimizations that conflict with toolbox
RUN rm -f /etc/apt/apt.conf.d/docker-*

# Remove the base image's UID 1000 user so Toolbx can create the host user.
RUN userdel --remove ubuntu && if getent group ubuntu >/dev/null; then groupdel ubuntu; fi

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
