FROM cgal/testsuite-docker:ubuntu
ARG dockerfile_url
ARG image_tag
ENV DOCKERFILE_URL=$dockerfile_url
ENV IMAGE_TAG=$image_tag

#add qt6 as it is not run on cgal.gf.com
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libgl-dev \
    qt6-base-dev \
    qt6-declarative-dev \
    libqt6opengl6-dev \
    libqt6svg6-dev \
    libqt6websockets6-dev

ENV CGAL_TEST_PLATFORM="Ubuntu-Latest-NO_DEPRECATED_CODE"
ENV CGAL_SUMMARY_NAME="Ubuntu-latest-NO_DEPRECATED_CODE"
ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-DCGAL_NO_DEPRECATED_CODE\")"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
