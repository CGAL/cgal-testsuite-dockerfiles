#!/bin/bash

if [ "$1" = ArchLinux ]
then
  docker build -t cgal/testsuite-docker:archlinux ./ArchLinux
  docker build -t cgal/testsuite-docker:archlinux-clang-svn ./ArchLinux-clang-svn
  docker build -t cgal/testsuite-docker:archlinux-cxx14 ./ArchLinux-clang-CXX14
  docker build -t cgal/testsuite-docker:archlinux-clang ./ArchLinux-clang
  docker build -t cgal/testsuite-docker:archlinux-clang-cxx1z ./ArchLinux-clang-CXX1z
  docker build -t cgal/testsuite-docker:archlinux-clang-cxx14 ./ArchLinux-clang-CXX14
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
elif [ "$1" = CentOS-7 ]
then
  docker build -t centos7 ./CentOS-7
  docker build -t cgal/testsuite-docker:centos7-release ./CentOS-7-Release
  docker build -t cgal/testsuite-docker:centos7-icc ./CentOS-7-ICC
  docker build -t cgal/testsuite-docker:centos7-icc-release ./CentOS-7-ICC-Release
  docker build -t cgal/testsuite-docker:centos7-icc-2016 ./CentOS-7-ICC-1016
  docker build -t cgal/testsuite-docker:centos7-icc-2016-release ./CentOS-7-ICC-1016-Release
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
  docker build -t cgal/testsuite-docker:fedora-rawhide ./Ubuntu
fi