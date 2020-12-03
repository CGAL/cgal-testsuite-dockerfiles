FROM cgal/testsuite-docker:fedora
MAINTAINER Laurent Rineau <laurent.rineau@cgal.org>

ENV CGAL_TEST_PLATFORM="Fedora-with-LEDA"
ENV LEDA_DIR="/mnt/testresults/leda-numbers/" LD_LIBRARY_PATH=/mnt/testresults/leda-numbers/
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
