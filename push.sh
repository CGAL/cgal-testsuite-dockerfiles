#!/bin/bash

set -e

if [ "$1" = ArchLinux ]
then
   docker push cgal/testsuite-docker:archlinux
   docker push cgal/testsuite-docker:archlinux-cxx14
   docker push cgal/testsuite-docker:archlinux-cxx17-release
   docker push cgal/testsuite-docker:archlinux-clang
   docker push cgal/testsuite-docker:archlinux-clang-cxx14
   docker push cgal/testsuite-docker:archlinux-clang-cxx17-release
   docker push cgal/testsuite-docker:archlinux-clang-release
elif [ "$1" = CentOS-5 ]
then
   docker push cgal/testsuite-docker:centos5
elif [ "$1" = CentOS-6 ]
then
   docker push cgal/testsuite-docker:centos6
   docker push cgal/testsuite-docker:centos6-cxx11-boost157
elif [ "$1" = CentOS-6-32 ]
then
   docker push cgal/testsuite-docker:centos6-32
elif [ "$1" = CentOS-7-ICC-beta ]
then
  docker push cgal/testsuite-docker:centos7-icc-beta
elif [ "$1" = CentOS-7-ICC ]
then
  docker push cgal/testsuite-docker:centos7-icc
elif [ "$1" = CentOS-7 ]
then
   docker push cgal/testsuite-docker:centos7
   docker push cgal/testsuite-docker:centos7-release
elif [ "$1" = Debian-stable ]
then
   docker push cgal/testsuite-docker:debian-stable
   docker push cgal/testsuite-docker:debian-stable-release
elif [ "$1" = Debian-testing ]
then
   docker push cgal/testsuite-docker:debian-testing
elif [ "$1" = Fedora ]
then
   docker push cgal/testsuite-docker:fedora
   docker push cgal/testsuite-docker:fedora-with-leda
   docker push cgal/testsuite-docker:fedora-release
   docker push cgal/testsuite-docker:fedora-strict-ansi
elif [ "$1" = Fedora-32 ]
then
   docker push cgal/testsuite-docker:fedora-32
   docker push cgal/testsuite-docker:fedora-32-release
elif [ "$1" = Fedora-rawhide ]
then
   docker push cgal/testsuite-docker:fedora-rawhide
   docker push cgal/testsuite-docker:fedora-rawhide-release
elif [ "$1" = Ubuntu ]
then
   docker push cgal/testsuite-docker:ubuntu
   docker push cgal/testsuite-docker:ubuntu-cxx11
   docker push cgal/testsuite-docker:ubuntu-gcc6
   docker push cgal/testsuite-docker:ubuntu-gcc6-cxx1z
   docker push cgal/testsuite-docker:ubuntu-gcc6-release
   docker push cgal/testsuite-docker:ubuntu-no-deprecated-code
fi
