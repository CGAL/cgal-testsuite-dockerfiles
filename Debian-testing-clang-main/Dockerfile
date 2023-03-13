FROM cgal/testsuite-docker:debian-testing
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url  

RUN apt-get update -y \
&& apt-get install wget \
&& apt-get install -y software-properties-common \
&& apt-get clean all \
&& cd .. && wget https://apt.llvm.org/llvm.sh \
&& chmod +x llvm.sh \
&& bash -x ./llvm.sh 16 \
&& rm ./llvm.sh 

ENV CXX=/usr/bin/clang++-16
ENV CC=/usr/bin/clang-16
ENV CGAL_TEST_PLATFORM="Debian-testing-clang-main"

