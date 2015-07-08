FROM cgal/testsuite-docker:centos6
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

# cgal/testsuite-docker:centos6 has a boost installation, remove it
RUN rm -rf /usr/local/include/boost
RUN rm -f /usr/local/lib/libboost_*

ENV BOOST_MAJOR=1 BOOST_MINOR=57 BOOST_PATCH=0
RUN curl -SL http://sourceforge.net/projects/boost/files/boost/${BOOST_MAJOR}.${BOOST_MINOR}.${BOOST_PATCH}/boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH}.tar.gz | tar xz
RUN cd boost_${BOOST_MAJOR}_${BOOST_MINOR}_${BOOST_PATCH} && \
    ./bootstrap.sh --without-libraries=filesystem,graph_parallel,python,iostreams,locale,mpi,serialization,signals,wave && \
    ./b2 cxxflags="-std=c++0x" linkflags="-std=c++0x" --prefix=/usr/local/ install

ENV CGAL_TEST_PLATFORM="CentOS6-CXX11-Boost157"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\" \"-DCGAL_CXX_FLAGS=-Wall -std=c++0x\")"
