FROM cgal/testsuite-docker:centos7
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

RUN yum -y update; yum clean all
RUN yum -y install \
    gcc-c++ \
    glibc-devel.x86_64 \
    libstdc++-devel.x86_64 \
    tar

RUN curl -SL http://registrationcenter-download.intel.com/akdlm/irc_nas/7538/parallel_studio_xe_2015_update3.tgz | tar xzv && \
    cd /parallel_studio_xe_2015_update3/rpm && \
    rpm -ivh --nodeps --ignorearch --excludedocs \
    intel-compilerpro-*.rpm \
    intel-compilerproc-*.rpm \
    intel-mkl-*.rpm && \ 
    cd / && rm -rf parallel_studio_xe_2015_update3

RUN source /opt/intel/composer_xe_2015.3.187/pkg_bin/compilervars.sh intel64 && source /opt/intel/composer_xe_2015.3.187/mkl/bin/mklvars.sh intel64
ENV CC=icc CXX=icpc
ENV CGAL_TEST_PLATFORM="CentOS7-ICC"
ENV CGAL_CMAKE_FLAGS=""