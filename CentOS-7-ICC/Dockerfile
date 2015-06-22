FROM centos:centos7
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

RUN yum -y update; yum clean all
RUN yum -y install gcc-c++ glibc-devel.x86_64 libstdc++-devel.x86_64 wget tar hostname man-db

# RUN wget http://registrationcenter-download.intel.com/akdlm/irc_nas/7538/parallel_studio_xe_2015_update3.tgz && tar -xzvf parallel_studio_xe_2015_update3.tgz
ADD parallel_studio_xe_2015_update3.tgz / # This automatically extracts
WORKDIR /parallel_studio_xe_2015_update3/rpm
RUN rpm -ivh --nodeps --ignorearch --exclude-docs \
    intel-compilerpro-*.rpm \
    intel-compilerproc-*.rpm \
    intel-mkl-*.rpm

# install.sh requires this variable set and will segfault if it is empty
# https://software.intel.com/es-es/forums/topic/539798
# WORKDIR /parallel_studio_xe_2015_update3/rpm
# ADD silent.cfg /tmp/silent.cfg
# ADD license.lic /tmp/license.lic
# ENV USER="root"
# RUN ./install.sh --silent /tmp/silent.cfg

ENV CGAL_TEST_PLATFORM="CentOS7-ICC"
ENV CGAL_CMAKE_FLAGS=""