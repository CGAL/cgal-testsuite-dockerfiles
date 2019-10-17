FROM cgal/testsuite-docker:fedora-rawhide
MAINTAINER Maxime Gimeno <maxime.gimeno@gmail.com>
RUN dnf -y install \
    libasan.x86_64 \
    tar && dnf clean all
ENV CGAL_TEST_PLATFORM="Fedora-rawhide-fsanitize"
ENV CGAL_CMAKE_FLAGS="( \"-DCMAKE_BUILD_TYPE=Debug\" \"-DCMAKE_CXX_FLAGS=-Og -g -fsanitize=address\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
