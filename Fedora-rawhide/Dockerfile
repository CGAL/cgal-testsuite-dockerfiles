FROM fedora:rawhide
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN trap "cat /var/log/dnf.rpm.log" EXIT && dnf -y upgrade && \
    [ -x /usr/bin/dnf ] || ln -s /usr/bin/dnf5 /usr/bin/dnf && \
    dnf -y install make cmake gcc-c++ \
                   util-linux \
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
                   zlib-ng-devel.x86_64 \
		           diffutils \
                   wget \
                   git \
                   lsb-release \
                   json-devel \
                   tar && \
    dnf clean all && \
    wget https://registrationcenter-download.intel.com/akdlm/irc_nas/19143/l_tbb_oneapi_p_2021.8.0.25334_offline.sh && \
    bash l_tbb_oneapi_p_2021.8.0.25334_offline.sh -a --action install --eula accept -s && \
    rm l_tbb_oneapi_p_2021.8.0.25334_offline.sh

ENV CGAL_TEST_PLATFORM="Fedora-rawhide"
ENV CGAL_CMAKE_FLAGS="('-DCGAL_HEADER_ONLY:BOOL=TRUE')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
