FROM centos:centos6
MAINTAINER Laurent Rineau <laurent.rineau@cgal.org>

RUN yum -y update; yum clean all
RUN yum -y install epel-release.noarch
RUN yum -y update; yum -y install make cmake gcc-c++ tar \
                   glibc-devel.i686 libstdc++-devel.i686 \
                   gmp-devel.i686 mpfr-devel.i686 \
                   qt-devel.i686 \
                   libQGLViewer-devel.i686 \
                   glew-devel.i686 \
                   eigen3-devel.noarch \
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

ENV BOOST_MAJOR=1
ENV BOOST_MINOR=48
ENV BOOST_PATCH=0
RUN curl -SL http://sourceforge.net/projects/boost/files/boost/${BOOST_MAJOR}.${BOOST_MINOR}.${BOOST_PATCH}/boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH}.tar.gz | tar xz
RUN cd boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH} && \
    ./bootstrap.sh --without-libraries=filesystem,graph_parallel,python,iostreams,locale,mpi,serialization,signals,wave && \
    ./b2 cflags=-m32 \
         cxxflags=-m32 \
         address-model=32 \
         threading=multi \
         architecture=x86 \
         instruction-set=i686 \
         --prefix=/usr/local/ install

ENV CGAL_TEST_PLATFORM="CentOS6-32"
ENV CGAL_CMAKE_FLAGS="(\"-DCMAKE_CXX_FLAGS=-m32\" \"-DCMAKE_SHARED_LINKER_FLAGS=-m32\" \"-DCGAL_CXX_FLAGS=-m32\" \"-DWITH_CGAL_Qt3:BOOL=OFF\")"
