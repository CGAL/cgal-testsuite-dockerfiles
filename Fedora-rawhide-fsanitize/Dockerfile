FROM cgal/testsuite-docker:fedora-rawhide as cgal-base
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url
ARG image_tag
ENV IMAGE_TAG=$image_tag
RUN dnf -y install \
    libasan.x86_64 \
    tar && dnf clean all
ENV CGAL_TEST_PLATFORM="Fedora-rawhide-fsanitize"
ENV CGAL_CMAKE_FLAGS="( \"-DCMAKE_BUILD_TYPE=Debug\" \"-DCMAKE_CXX_FLAGS=-Og -g -fsanitize=address\")"
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

# Install toolbox tools and enable passwordless sudo for the wheel group
RUN dnf install -y sudo zsh && \
    printf '%s\n' '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-toolbox && \
    chmod 0440 /etc/sudoers.d/99-toolbox && \
    dnf clean all
