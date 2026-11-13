FROM archlinux:base-devel AS cgal-common

# Install additional packages beyond the baseline.
# Install dependencies of the AUR (user repository) packages to be built from source later
#   ipe: freetype2, lua, poppler, python3, zlib
#   leda-free: tcsh
# and clean up the package cache
RUN pacman-key --init && pacman --noconfirm -Syu archlinux-keyring && \
    pacman -Syu --noconfirm && pacman -S --needed --noconfirm \
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
    && pacman -Scc --noconfirm
# Install the latest CMake from the `next` branch on GitHub.
RUN git clone --branch next --depth 1 https://github.com/Kitware/CMake.git \
    && cd ./CMake \
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
    useradd -u 10000 -g makepkg makepkg && \
    mkdir /tmp/makepkg && \
    chown -R makepkg:makepkg /tmp/makepkg && \
    mkdir /home/makepkg && \
    chown -R makepkg:makepkg /home/makepkg

# get and build AUR packages
USER 10000
WORKDIR /tmp/makepkg
RUN set -e; \
    for PKG in ipe esbtl leda-free librs; do \
        if curl -sSL -o "${PKG}.tar.gz" "https://aur.archlinux.org/cgit/aur.git/snapshot/${PKG}.tar.gz" && \
           tar xzf "${PKG}.tar.gz" && \
           rm "${PKG}.tar.gz" && \
           cd "${PKG}" && MAKEFLAGS="-j$(nproc)" makepkg --noconfirm; then \
               cd /tmp/makepkg; \
               mv "${PKG}"/*.pkg.tar.zst .; \
               rm -rf "${PKG}"; \
        else \
               echo "Failed to build required AUR package ${PKG}" >&2; \
               exit 1; \
        fi; \
        cd /tmp/makepkg; \
    done

# install AUR packages and get rid of the build directories afterwards
# The testsuite and toolbox image require a root default.
# hadolint ignore=DL3002
USER 0
WORKDIR /tmp/makepkg
RUN pacman -U --noconfirm ./*.pkg.tar.zst && \
    rm ./*.pkg.tar.zst && \
    pacman -Scc --noconfirm

RUN pacman -Syu --noconfirm --needed unzip wget && pacman -Scc --noconfirm

# Copy and run the script to install LAStools
COPY --from=root install_lastools.sh LAStools.patch /tmp/
RUN bash /tmp/install_lastools.sh

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

COPY --from=root ArchLinux/toolbox-setup.sh /tmp/toolbox-setup.sh
RUN sh /tmp/toolbox-setup.sh && rm /tmp/toolbox-setup.sh
