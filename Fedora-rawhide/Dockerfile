FROM fedora:rawhide
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

RUN yum -y install dnf && yum clean all && \
    dnf -y update && dnf clean all

# Note: tar is already installed
RUN dnf -y install make cmake gcc-c++ \
                   glibc-devel.x86_64 libstdc++-devel.x86_64 \
                   gmp-devel.x86_64 mpfr-devel.x86_64 \
                   boost-devel.x86_64 \
                   qt3-devel.x86_64 qt-devel.x86_64 \
                   libQGLViewer-devel.x86_64 \
                   ntl-devel.x86_64 \
                   glew-devel.x86_64 \
                   ipe-devel.x86_64 \
                   eigen3-devel.noarch \
                   qt5-qtbase-devel.x86_64 \
                   qt5-qtscript-devel.x86_64 \
                   qt5-qtsvg-devel.x86_64 \
                   qt5-qttools-devel.x86_64 \
                   /usr/lib64/libX11.so /usr/lib64/libSM.so \
                   /usr/lib64/libpng.so /usr/lib64/libICE.so \
                   /usr/lib64/libGL.so /usr/lib64/libGLU.so \
                   /usr/lib64/libXi.so /usr/lib64/libXrender.so \
                   /usr/lib64/libXrandr.so /usr/lib64/libXcursor.so \
                   /usr/lib64/libXinerama.so \
                   /usr/lib64/libXfixes.so /usr/lib64/libXext.so \
                   /usr/lib64/libXdamage.so /usr/lib64/libXft.so \
                   /usr/lib64/libXt.so /usr/lib64/libXau.so \
                   /usr/lib64/libXxf86vm.so /usr/lib64/libjpeg.so \
                   /usr/lib64/libxcb.so /usr/lib64/libdrm.so \
                   /usr/lib64/libfreetype.so /usr/lib64/libfontconfig.so \
                   zlib-devel.x86_64

# Enable lrineau's copr repo to get libQGLViewer for Qt5.
RUN dnf -y install 'dnf-command(copr)' && \
    rpm --import https://copr-be.cloud.fedoraproject.org/results/rineau/libQGLViewer-qt5/pubkey.gpg && \
    dnf -y copr enable rineau/libQGLViewer-qt5 && dnf -y install libQGLViewer-qt5-devel.x86_64 && \
    dnf clean all

ENV QTDIR=/usr/lib/qt-3.3/
ENV QTINC=/usr/lib/qt-3.3/include/
ENV QTLIB=/usr/lib/qt-3.3/lib/

ENV CGAL_TEST_PLATFORM="Fedora-rawhide"
ENV CGAL_CMAKE_FLAGS=""
