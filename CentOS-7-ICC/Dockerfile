FROM cgal/testsuite-docker:centos7
MAINTAINER Maxime Gimeno <maxime.gimeno@gmail.com>

RUN yum -y install \
    wget \
    gcc-c++ \
    glibc-devel.x86_64 \
    libstdc++-devel.x86_64 \
    tar && yum clean all

COPY config.cfg /tmp/icc-config.cfg

RUN cd /tmp && \
  wget -O icc.tgz http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/11542/parallel_studio_xe_2017_update4_composer_edition_for_cpp_online.tgz && \
  tar -xvzf icc.tgz && \
  cd /tmp/parallel_studio_xe_* && \
  bash ./install.sh --silent=/tmp/icc-config.cfg && \
  cd .. && \
  rm -rf parallel_studio_xe_* icc.tgz && \
  rm /tmp/icc-config.cfg

COPY intel.sh /etc/profile.d/intel.sh

ENV CC=icc CXX=icpc BASH_ENV=/etc/profile.d/intel.sh
ENV CGAL_TEST_PLATFORM="CentOS7-ICC"
ENV CGAL_CMAKE_FLAGS="('-DCMAKE_CXX_FLAGS=-w1')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
