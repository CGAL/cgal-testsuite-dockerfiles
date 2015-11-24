FROM cgal/testsuite-docker:centos7
MAINTAINER Philipp Moeller <bootsarehax@gmail.com>

RUN yum -y update; yum clean all
RUN yum -y install \
    gcc-c++ \
    glibc-devel.x86_64 \
    libstdc++-devel.x86_64 \
    tar

RUN curl -SL http://registrationcenter-download.intel.com/akdlm/irc_nas/8365/parallel_studio_xe_2016_update1.tgz | tar xzv && \
    cd /parallel_studio_xe_2016/rpm && \
    rpm -ivh --nodeps --ignorearch --excludedocs \
    intel-icc-*.x86_64.rpm intel-icc-*.noarch.rpm \
    intel-comp-*.x86_64.rpm intel-comp-*.noarch.rpm \
    intel-mkl-*.x86_64.rpm intel-mkl-*.noarch.rpm \
    intel-openmp-*.x86_64.rpm && \ 
    cd / && rm -rf parallel_studio_xe_2016

RUN echo "source /opt/intel/compilers_and_libraries_2016.0.109/linux/bin/compilervars.sh intel64 \&\& source /opt/intel/compilers_and_libraries_2016.0.109/linux/mkl/bin/mklvars.sh intel64" > /etc/profile.d/intel.sh
ENV CC=icc CXX=icpc BASH_ENV=/etc/profile.d/intel.sh
ENV CGAL_TEST_PLATFORM="CentOS7-ICC-2016"
ENV CGAL_CMAKE_FLAGS="('-DCMAKE_CXX_FLAGS=-w1')"
