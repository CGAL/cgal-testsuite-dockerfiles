FROM cgal/testsuite-docker:centos7
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN yum -y update; yum clean all
RUN yum -y install \
    gcc-c++ \
    glibc-devel.x86_64 \
    libstdc++-devel.x86_64 \
    tar

RUN curl -s -SL http://registrationcenter-download.intel.com/akdlm/irc_nas/9781/parallel_studio_xe_2016_update4.tgz | tar xz && \
    cd /parallel_studio_xe_2016_update4/rpm && \
    rpm -ivh --nodeps --ignorearch --excludedocs \
    $(for p in intel-icc-*.x86_64.rpm intel-icc-*.noarch.rpm \
    intel-comp-*.x86_64.rpm intel-comp-*.noarch.rpm \
    intel-mkl-*.x86_64.rpm intel-mkl-*.noarch.rpm \
    intel-openmp-*.x86_64.rpm; do echo $p; done | grep -v -- -jp- ) && \
    cd / && rm -rf parallel_studio_xe_2016_update4

RUN echo "if [ "$GUARD" != "1" ]; then source /opt/intel/compilers_and_libraries_2016.4.258/linux/bin/compilervars.sh intel64 \&\& source /opt/intel/compilers_and_libraries_2016.4.258/linux/mkl/bin/mklvars.sh intel64 \&\& source /opt/intel/compilers_and_libraries_2016.4.258/linux/tbb/bin/tbbvars.sh intel64; fi; export GUARD=1" > /etc/profile.d/intel.sh
ENV CC=icc CXX=icpc BASH_ENV=/etc/profile.d/intel.sh
ENV CGAL_TEST_PLATFORM="CentOS7-ICC-2016"
ENV CGAL_CMAKE_FLAGS="('-DCMAKE_CXX_FLAGS=-w1')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
