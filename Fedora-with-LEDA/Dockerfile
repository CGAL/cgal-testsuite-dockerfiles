FROM cgal/testsuite-docker:fedora
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

ENV CGAL_TEST_PLATFORM="Fedora-with-LEDA"
ENV LEDA_DIR="/mnt/testresults/leda-numbers/" LD_LIBRARY_PATH=/mnt/testresults/leda-numbers/
ENV INIT_FILE=/tmp/init.cmake
ENV CGAL_DISABLE_GMP=ON
COPY init.cmake /tmp/init.cmake
