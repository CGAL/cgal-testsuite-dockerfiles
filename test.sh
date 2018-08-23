#!/bin/bash

set -e

if [ "$1" = ArchLinux ]
then
  docker build -t cgal/testsuite-docker:archlinux ./ArchLinux
  docker build -t cgal/testsuite-docker:archlinux-cxx14 ./ArchLinux-CXX14
  docker build -t cgal/testsuite-docker:archlinux-cxx17-release ./ArchLinux-CXX17-Release
  docker build -t cgal/testsuite-docker:archlinux-clang ./ArchLinux-clang
  docker build -t cgal/testsuite-docker:archlinux-clang-cxx14 ./ArchLinux-clang-CXX14
  docker build -t cgal/testsuite-docker:archlinux-clang-cxx17-release ./ArchLinux-clang-CXX17-Release
  docker build -t cgal/testsuite-docker:archlinux-clang-release ./ArchLinux-clang-Release
elif [ "$1" = CentOS-5 ]
then
  docker build -t cgal/testsuite-docker:centos5 ./CentOS-5
elif [ "$1" = CentOS-6 ]
then
  docker build -t cgal/testsuite-docker:centos6 ./CentOS-6
  docker build -t cgal/testsuite-docker:centos6-cxx11-boost157 ./CentOS-6-CXX11-Boost157
elif [ "$1" = CentOS-6-32 ]
then
  docker build -t cgal/testsuite-docker:centos6-32 ./CentOS-6-32
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
  docker build -t cgal/testsuite-docker:centos7-icc ./CentOS-7-ICC
elif [ "$1" = CentOS-7 ]
then
  docker build -t cgal/testsuite-docker:centos7 ./CentOS-7
  docker build -t cgal/testsuite-docker:centos7-release ./CentOS-7-Release
elif [ "$1" = Debian-stable ]
then
  docker build -t cgal/testsuite-docker:debian-stable ./Debian-stable
  docker build -t cgal/testsuite-docker:debian-stable-release ./Debian-stable-Release
elif [ "$1" = Debian-testing ]
then
  docker build -t cgal/testsuite-docker:debian-testing ./Debian-testing
elif [ "$1" = Fedora ]
then
  docker build -t cgal/testsuite-docker:fedora ./Fedora
  docker build -t cgal/testsuite-docker:fedora-with-leda ./Fedora-with-LEDA
  docker build -t cgal/testsuite-docker:fedora-release ./Fedora-Release
  docker build -t cgal/testsuite-docker:fedora-strict-ansi ./Fedora-strict-ansi
elif [ "$1" = Fedora-32 ]
then
  docker build -t cgal/testsuite-docker:fedora-32 ./Fedora-32
  docker build -t cgal/testsuite-docker:fedora-32-release ./Fedora-32-Release
elif [ "$1" = Fedora-rawhide ]
then
  docker build -t cgal/testsuite-docker:fedora-rawhide ./Fedora-rawhide
  docker build -t cgal/testsuite-docker:fedora-rawhide-release ./Fedora-rawhide-Release
elif [ "$1" = Ubuntu ]
then
  docker build -t cgal/testsuite-docker:ubuntu ./Ubuntu
  docker build -t cgal/testsuite-docker:ubuntu-cxx11 ./Ubuntu-CXX11
  docker build -t cgal/testsuite-docker:ubuntu-gcc6 ./Ubuntu-GCC6
  docker build -t cgal/testsuite-docker:ubuntu-gcc6-cxx1z ./Ubuntu-GCC6-CXX1Z
  docker build -t cgal/testsuite-docker:ubuntu-gcc6-release ./Ubuntu-GCC6-Release
  docker build -t cgal/testsuite-docker:ubuntu-no-deprecated-code ./Ubuntu-NO_DEPRECATED_CODE
fi
docker images
