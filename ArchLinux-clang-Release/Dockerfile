FROM cgal/testsuite-docker:archlinux-clang
ARG dockerfile_url

ENV CGAL_TEST_PLATFORM="ArchLinux-clang-Release"
ENV CGAL_CMAKE_FLAGS="('-DCMAKE_BUILD_TYPE=Release' '-DCMAKE_CXX_FLAGS_RELEASE=-O3 -DCGAL_NDEBUG' '-DWITH_CGAL_Qt3:BOOL=OFF' '-DCMAKE_POLICY_DEFAULT_CMP0053=OLD' '-DLEDA_INCLUDE_DIR=/usr/include/LEDA' '-DCMAKE_C_COMPILER:FILEPATH=/bin/clang' '-DCMAKE_CXX_COMPILER:FILEPATH=/bin/clang++' '-DCGAL_CXX_FLAGS=-Wall -march=native' '-DWITH_GMPXX:BOOL=ON')" CXX=/bin/clang++ CC=/bin/clang
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
