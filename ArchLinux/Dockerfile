FROM archlinux:base-devel AS cgal-base
ARG dockerfile_url
ARG image_tag
ENV DOCKERFILE_URL=$dockerfile_url
ENV IMAGE_TAG=$image_tag

# Install additional packages beyond the baseline.
# Install dependencies of the AUR (user repository) packages to be built from source later
#   ipe: freetype2, lua, poppler, python3, zlib
#   leda-free: tcsh
# and clean up the package cache
RUN pacman-key --init && pacman --noconfirm -Syu archlinux-keyring
RUN pacman -Syu --noconfirm && pacman -S --needed --noconfirm \
              base-devel \
              patch \
              coreutils \
              git \
              lsb-release \
              boost \
              boost-libs \
              eigen \
              glew glu mesa \
              gmp mpfr mpfi ntl \
              qt5-base qt5-script qt5-svg qt5-tools \
              qt6-base qt6-tools qt6-svg qt6-websockets qt6-declarative \
	          intel-tbb \
                  nlohmann-json \
    && pacman -S --needed --noconfirm --asdeps \
                 freetype2 lua poppler python3 zlib \
                 tcsh \
    && pacman -Scc
#Install latest cmake from the `next` branch on github
RUN git clone https://github.com/Kitware/CMake.git --depth 1 \
    && cd ./CMake \
    && git branch next \
    && mkdir build \
    && cd build \
    && env CC=cc CXX=c++ ../bootstrap \
    && make -j"$(nproc)" \
    && make install \
    && cd ../.. \
    && rm -rf ./CMake

# create a group for building AUR (user contributed) packages from sources
# (not allowed as root for security reasons)
RUN groupadd -r makepkg && \
    useradd -r -g makepkg makepkg && \
    mkdir /tmp/makepkg && \
    chown -R makepkg:makepkg /tmp/makepkg && \
    mkdir /home/makepkg && \
    chown -R makepkg:makepkg /home/makepkg

# get and build AUR packages
USER makepkg
WORKDIR /tmp/makepkg
RUN set -e; \
    for PKG in ipe esbtl leda-free librs; do \
        if curl -sSL https://aur.archlinux.org/cgit/aur.git/snapshot/${PKG}.tar.gz | tar xzv && \
           cd ${PKG} && makepkg --noconfirm; then \
               cd /tmp/makepkg; \
               mv ${PKG}/*.pkg.tar.zst .; \
               rm -rf ${PKG}; \
        fi; \
        cd /tmp/makepkg; \
    done

# install AUR packages and get rid of the build directories afterwards
USER root
WORKDIR /tmp/makepkg
RUN pacman -U --noconfirm ./*.pkg.tar.zst && \
    rm ./*.pkg.tar.zst

RUN pacman -Sy --noconfirm unzip wget  && pacman -Scc

# Copy and run the script to install LAStools
COPY --from=root install_lastools.sh LAStools.patch /tmp/
RUN chmod +x /tmp/install_lastools.sh && bash /tmp/install_lastools.sh

# LEDA includes are in a nonstandard location (/usr/include/LEDA/LEDA/...
# instead of just /usr/include/LEDA/...) in Stephan Friedrich's AUR package,
# to avoid conflicts with other files.
#
# The CMAKE_GENERATOR trick is used to pass a CMake variable to each CMake
# run by the testsuite.
#
ENV CGAL_TEST_PLATFORM="ArchLinux" \
    LEDA_INC_DIR=/usr/include/LEDA

# Try to fix a strange bug with clang
# where make complains about files in /include:
#
#    Prerequisite '/include/c++/13.2.1/algorithm' of target 'test/AABB_tree_Demo/CMakeFiles/CGAL_Qt6_moc_and_resources.dir/CGAL_Qt6_moc_and_resources_autogen/mocs_compilation.cpp.o' does not exist.
RUN ln -s /usr/include /include
ENV CGAL_SUMMARY_NAME="ArchLinux-basedevel-Debug"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake

# ===== STAGE 2: Toolbox Variant =====
# Derived from cgal-base with toolbox-specific configurations
FROM cgal-base AS cgal-toolbox

LABEL com.github.containers.toolbox="true" \
      name="cgal-toolbox" \
      usage="This image is meant to be used with the toolbox command"

# Configure hostname resolution for toolbox compatibility
RUN grep -Eq '^hosts:.*[[:space:]]myhostname([[:space:]]|$)' /etc/nsswitch.conf || sed -Ei 's/^(hosts:.*\<files\>)/\1 myhostname/' /etc/nsswitch.conf

# Create required directories for toolbox
RUN mkdir -p /usr/share/empty /etc/pkcs11/modules /etc/krb5.conf.d

# Install sudo and zsh for toolbox environment
RUN pacman -Syu --noconfirm sudo zsh systemd-libs libcap shadow flatpak-xdg-utils p11-kit vte-common && \
    printf '%s\n' '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/99-toolbox && \
    chmod 0440 /etc/sudoers.d/99-toolbox && \
    pacman -Scc --noconfirm && \
    rm -rf /home/makepkg
