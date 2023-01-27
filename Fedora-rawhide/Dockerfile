FROM fedora:rawhide
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN echo "install  make cmake gcc-c++ \
                   gmp-devel.x86_64 mpfr-devel.x86_64 \
                   boost-devel.x86_64 \
                   ntl-devel.x86_64 \
                   ipe-devel.x86_64 \
                   eigen3-devel.noarch \
                   qt5-qtbase-devel.x86_64 \
                   qt5-qtscript-devel.x86_64 \
                   qt5-qtsvg-devel.x86_64 \
                   qt5-qttools-devel.x86_64 \
                   libQGLViewer-qt5-devel.x86_64 \
                   mesa-libGLU-devel \
                   OpenMesh-devel \
                   zlib-devel.x86_64 \
		           diffutils \
                   wget \
                   tar" >> dnf-cmd && \
    echo update >> dnf-cmd && \
    echo run >> dnf-cmd && \
    dnf -y --refresh shell dnf-cmd && rm dnf-cmd && \
    dnf clean all && \
    wget https://registrationcenter-download.intel.com/akdlm/irc_nas/19143/l_tbb_oneapi_p_2021.8.0.25334_offline.sh && \
    bash l_tbb_oneapi_p_2021.8.0.25334_offline.sh -a --action install --eula accept -s && \
    rm l_tbb_oneapi_p_2021.8.0.25334_offline.sh

ENV CGAL_TEST_PLATFORM="Fedora-rawhide"
ENV CGAL_CMAKE_FLAGS="('-DCGAL_HEADER_ONLY:BOOL=TRUE')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
