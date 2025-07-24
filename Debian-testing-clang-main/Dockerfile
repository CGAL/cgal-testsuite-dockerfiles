FROM cgal/testsuite-docker:debian-testing
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN apt-get update -y && apt-get install -y wget \
&& wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc \
&& echo 'deb http://apt.llvm.org/unstable/ llvm-toolchain main' > /etc/apt/sources.list.d/llvm.list \
&& apt-get update -y \
&& apt-get install -y clang-22 \
&& apt-get clean all

ENV CXX=/usr/bin/clang++-22
ENV CC=/usr/bin/clang-22
ENV CGAL_TEST_PLATFORM="Debian-testing-clang-main"
ENV CGAL_SUMMARY_NAME="Debian-testing-clang-main"
