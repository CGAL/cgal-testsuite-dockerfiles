FROM centos:centos6
MAINTAINER Laurent Rineau <laurent.rineau@cgal.org>

RUN yum -y update; yum clean all
RUN yum -y install epel-release.noarch
RUN yum -y update; yum -y install cmake gcc-c++ tar \
                   glibc-devel.x86_64 libstdc++-devel.x86_64 \
                   gmp-devel.x86_64 mpfr-devel.x86_64 \
                   qt-devel.x86_64 \
                   libQGLViewer-devel.x86_64 \
                   glew-devel.x86_64 \
                   eigen3-devel.noarch \
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
RUN yum clean all

ENV BOOST_MAJOR=1 BOOST_MINOR=48 BOOST_PATCH=0
RUN curl -SL http://sourceforge.net/projects/boost/files/boost/${BOOST_MAJOR}.${BOOST_MINOR}.${BOOST_PATCH}/boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH}.tar.gz | tar xz
RUN cd boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH} && \
    ./bootstrap.sh --without-libraries=filesystem,graph_parallel,python,iostreams,locale,mpi,serialization,signals,wave && \
    ./b2 --prefix=/usr/local/ install

ENV CGAL_TEST_PLATFORM="CentOS6"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\")"
