#!/bin/bash

set -e

if [ -n "$GITHUB_SHA" ]; then
  COMMIT_URL=https://github.com/${GITHUB_REPOSITORY}/blob/${GITHUB_SHA}
fi

function dockerbuild() {
  if [ -z "$GITHUB_SHA" ]; then
    docker build -t cgal/testsuite-docker:$1 ./$2
  else
    docker build --build-arg dockerfile_url=${COMMIT_URL}/$2/Dockerfile -t cgal/testsuite-docker:$1 ./$2
  fi
}

if [ "$1" = ArchLinux ]
then
  dockerbuild archlinux ArchLinux
  dockerbuild archlinux-cxx14 ArchLinux-CXX14
  dockerbuild archlinux-cxx17-release ArchLinux-CXX17-Release
  dockerbuild archlinux-clang ArchLinux-clang
  dockerbuild archlinux-clang-cxx14 ArchLinux-clang-CXX14
  dockerbuild archlinux-clang-cxx17-release ArchLinux-clang-CXX17-Release
  dockerbuild archlinux-clang-cxx20-release ArchLinux-clang-CXX20-Release
  dockerbuild archlinux-clang-release ArchLinux-clang-Release
elif [ "$1" = CentOS-5 ]
then
  dockerbuild centos5 CentOS-5
elif [ "$1" = CentOS-6 ]
then
  dockerbuild centos6 CentOS-6
  dockerbuild centos6-cxx11-boost157 CentOS-6-CXX11-Boost157
elif [ "$1" = CentOS-6-32 ]
then
  dockerbuild centos6-32 CentOS-6-32
elif [ "$1" = CentOS-7-ICC-beta ]
then
    if [ -z "$ICC_BETA_ACTIVATION_SERIAL_NUMBER" -a -n "$TRAVIS_PULL_REQUEST" ]; then
        echo "The build of this image is deactivated in pull-requests"
    else
        echo ACTIVATION_SERIAL_NUMBER=$ICC_BETA_ACTIVATION_SERIAL_NUMBER > secret.file
        # Trick to share the secret with the building container, without
        # having the secret appear in the history of the built image:
        # transmit the secret at built time by http.
        docker network inspect local || docker network create local
        docker run --network local --name web -v $PWD/secret.file:/usr/share/nginx/html/index.html -d nginx
        docker build --network local -t cgal/testsuite-docker:centos7-icc-beta ./CentOS-7-ICC-beta
    fi
elif [ "$1" = CentOS-7-ICC ]
then
  dockerbuild centos7-icc CentOS-7-ICC
elif [ "$1" = CentOS-7 ]
then
  dockerbuild centos7 CentOS-7
  dockerbuild centos7-release CentOS-7-Release
elif [ "$1" = Debian-stable ]
then
  dockerbuild debian-stable Debian-stable
  dockerbuild debian-stable-release Debian-stable-Release
  dockerbuild debian-stable-cross-compilation-for-arm Debian-stable-cross-compilation-for-arm
elif [ "$1" = Debian-testing ]
then
  dockerbuild debian-testing Debian-testing
elif [ "$1" = Fedora ]
then
  dockerbuild fedora Fedora
  dockerbuild fedora-with-leda Fedora-with-LEDA
  dockerbuild fedora-release Fedora-Release
  dockerbuild fedora-strict-ansi Fedora-strict-ansi
elif [ "$1" = Fedora-32 ]
then
  dockerbuild fedora-32 Fedora-32
  dockerbuild fedora-32-release Fedora-32-Release
elif [ "$1" = Fedora-rawhide ]
then
  dockerbuild fedora-rawhide Fedora-rawhide
  dockerbuild fedora-rawhide-release Fedora-rawhide-Release
elif [ "$1" = Ubuntu ]
then
  dockerbuild ubuntu Ubuntu
  dockerbuild ubuntu-cxx11 Ubuntu-CXX11
  dockerbuild ubuntu-no-deprecated-code Ubuntu-NO_DEPRECATED_CODE
  dockerbuild ubuntu-no-gmp-no-leda Ubuntu-no-gmp-no-leda
elif [ "$1" = Ubuntu-GCC-master ]
then
  dockerbuild ubuntu-gcc6 Ubuntu-GCC6
  dockerbuild ubuntu-gcc6-cxx1z Ubuntu-GCC6-CXX1Z
  dockerbuild ubuntu-gcc6-release Ubuntu-GCC6-Release
  dockerbuild ubuntu-gcc_master_cxx20-release Ubuntu-GCC_master_cpp20-Release
fi
docker images
