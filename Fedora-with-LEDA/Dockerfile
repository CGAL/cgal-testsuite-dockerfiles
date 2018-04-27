FROM cgal/testsuite-docker:fedora
MAINTAINER Laurent Rineau <laurent.rineau@cgal.org>

ENV CGAL_TEST_PLATFORM="Fedora-with-LEDA"
ENV CGAL_CMAKE_FLAGS="('-DCMAKE_BUILD_TYPE=Release' '-DCMAKE_CXX_FLAGS_RELEASE=-O3 -DCGAL_NDEBUG' '-DCGAL_DISABLE_GMP=ON' '-DWITH_LEDA=ON' )" LEDA_DIR="/mnt/testresults/leda-numbers/" LD_LIBRARY_PATH=/mnt/testresults/leda-numbers/
