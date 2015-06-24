FROM cgal/testsuite-docker:centos6
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

# cgal/testsuite-docker:centos6 has a boost installation, remove it
RUN rm -rf /usr/local/include/boost
RUN rm -f /usr/local/lib/libboost_*

# RUN wget http://sourceforge.net/projects/boost/files/boost/1.57.0/boost_1_57_0.tar.gz && tar -xzvf boost_1_57_0.tar.gz
# RUN cd boost_1_57_0 && ./bootstrap.sh && ./b2 cxxflags="-std=c++0x" linkflags="-std=c++0x" --prefix=/usr/local/ --without-python --without-wave --without-signals -j4 install

ENV CGAL_TEST_PLATFORM="CentOS6-CXX11-Boost157"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\" \"-DCGAL_CXX_FLAGS=-Wall -std=c++0x\")"
