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
   docker push cgal/testsuite-docker:archlinux-clang-cxx20-release
   docker push cgal/testsuite-docker:archlinux-clang-release
elif [ "$1" = Debian-stable ]
then
   docker push cgal/testsuite-docker:debian-stable
   docker push cgal/testsuite-docker:debian-stable-release
   docker push cgal/testsuite-docker:debian-stable-cross-compilation-for-arm
elif [ "$1" = Debian-testing ]
then
   docker push cgal/testsuite-docker:debian-testing
   docker push cgal/testsuite-docker:debian-testing-clang-main
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
   docker push cgal/testsuite-docker:ubuntu-no-deprecated-code
   docker push cgal/testsuite-docker:ubuntu-no-gmp-no-leda
elif [ "$1" = Ubuntu-GCC-master ]
then
   docker push cgal/testsuite-docker:ubuntu-gcc6
   docker push cgal/testsuite-docker:ubuntu-gcc6-cxx1z
   docker push cgal/testsuite-docker:ubuntu-gcc6-release
   docker push cgal/testsuite-docker:ubuntu-gcc_master_cxx20-release
fi
