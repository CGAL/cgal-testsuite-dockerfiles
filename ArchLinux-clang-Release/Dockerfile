FROM cgal/testsuite-docker:archlinux-clang
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

ENV CGAL_TEST_PLATFORM="ArchLinux-clang-Release"
ENV CGAL_CMAKE_FLAGS="(\"-DCMAKE_BUILD_TYPE=Release\" \"-DCMAKE_CXX_FLAGS_RELEASE=-O3 -DCGAL_NDEBUG\" \"-DWITH_CGAL_Qt3:BOOL=OFF\" \"-DLEDA_INCLUDE_DIR=/usr/include/LEDA\" \"-DCMAKE_C_COMPILER:FILEPATH=/bin/clang\" \"-DCMAKE_CXX_COMPILER:FILEPATH=/bin/clang++\" \"-DCGAL_CXX_FLAGS=-Wall\")" CXX=/bin/clang++ CC=/bin/clang
