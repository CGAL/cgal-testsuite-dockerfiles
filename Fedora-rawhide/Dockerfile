FROM fedora:rawhide
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN rpm --import https://src.fedoraproject.org/rpms/fedora-repos/blob/main/f/RPM-GPG-KEY-fedora-35-primary && \
        echo $'[oneAPI] \n\
name=Intel® oneAPI repository \n\
baseurl=https://yum.repos.intel.com/oneapi \n\
enabled=1 \n\
gpgcheck=1 \n\
repo_gpgcheck=1 \n\
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB' >> /tmp/oneAPI.repo && \
    sudo mv /tmp/oneAPI.repo /etc/yum.repos.d && \
    echo "install make cmake gcc-c++ \
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
                   tar" >> dnf-cmd && \
    rpm --import https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB || true && \
    dnf --destdir /root --downloadonly install intel-oneapi-tbb-devel --nogpgcheck -y && \
    rpm -i --nosignature /root/*.rpm && \
    echo update >> dnf-cmd && \
    echo run >> dnf-cmd && \
    dnf -y shell dnf-cmd && rm dnf-cmd && \
    dnf clean all
ENV CGAL_TEST_PLATFORM="Fedora-rawhide"
ENV CGAL_CMAKE_FLAGS="('-DCGAL_HEADER_ONLY:BOOL=TRUE')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
