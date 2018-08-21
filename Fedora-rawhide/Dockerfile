FROM fedora:rawhide
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

RUN rpm --import https://src.fedoraproject.org/rpms/fedora-repos/raw/master/f/RPM-GPG-KEY-fedora-30-primary && \
    dnf -y update && \
    dnf -y install make cmake gcc-c++ \
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
                   tbb-devel \
                   zlib-devel.x86_64 \
                   tar && dnf clean all

ENV CGAL_TEST_PLATFORM="Fedora-rawhide"
ENV CGAL_CMAKE_FLAGS="('-DCGAL_HEADER_ONLY:BOOL=TRUE')"
