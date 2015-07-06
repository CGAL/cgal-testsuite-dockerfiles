From cgal/testsuite-docker:archlinux
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

RUN pacman -S --noconfirm clang
RUN pacman -Scc --noconfirm # clean up

ENV CGAL_TEST_PLATFORM="ArchLinux-clang"
ENV CGAL_CMAKE_FLAGS="(\"-DWITH_CGAL_Qt3:BOOL=OFF\" \"-DCMAKE_C_COMPILER:FILEPATH=/bin/clang\" \"-DCMAKE_CXX_COMPILER:FILEPATH=/bin/clang++\" \"-DCGAL_CXX_FLAGS=-Wall\")" CXX=/bin/clang++ CC=/bin/clang
