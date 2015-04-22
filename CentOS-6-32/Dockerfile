FROM centos:centos6
MAINTAINER Laurent Rineau <laurent.rineau@cgal.org>

RUN yum -y update; yum clean all
RUN yum -y install cmake gcc-c++  \
                   glibc-devel.i686 libstdc++-devel.i686 \
                   gmp-devel.i686 mpfr-devel.i686 \
                   boost-devel.i686 \
                   qt3-devel.i686 qt-devel.i686 \
                   /usr/lib/libX11.so /usr/lib/libSM.so \
                   /usr/lib/libpng.so /usr/lib/libICE.so \
                   /usr/lib/libGL.so /usr/lib/libGLU.so \
                   /usr/lib/libXi.so /usr/lib/libXrender.so \
                   /usr/lib/libXrandr.so /usr/lib/libXcursor.so \
                   /usr/lib/libXinerama.so \
                   /usr/lib/libXfixes.so /usr/lib/libXext.so \
                   /usr/lib/libXdamage.so /usr/lib/libXft.so \
                   /usr/lib/libXt.so /usr/lib/libXau.so \
                   /usr/lib/libXxf86vm.so /usr/lib/libjpeg.so \
                   /usr/lib/libxcb.so /usr/lib/libdrm.so \
                   /usr/lib/libfreetype.so /usr/lib/libfontconfig.so \
                   zlib-devel.i686
RUN yum clean all
