#!/bin/bash

set -e

[ -n "$ACTIONS_RUNNER_DEBUG" ] && set -x

if [ "$1" = ArchLinux ]
then
  make -j "$(nproc)" --output-sync=recurse archlinux archlinux-cxx14 archlinux-cxx17-release archlinux-clang archlinux-clang-cxx14 archlinux-clang-cxx17-release archlinux-clang-cxx20-release archlinux-clang-release
elif [ "$1" = Debian-stable ]
then
  make -j "$(nproc)" --output-sync=recurse debian-stable debian-stable-release debian-stable-cross-compilation-for-arm
elif [ "$1" = Debian-testing ]
then
  make -j "$(nproc)" --output-sync=recurse debian-testing debian-testing-clang-main
elif [ "$1" = Fedora ]
then
  make -j "$(nproc)" --output-sync=recurse fedora fedora-with-leda fedora-release fedora-strict-ansi
elif [ "$1" = Fedora-32 ]
then
  make -j "$(nproc)" --output-sync=recurse fedora-32 fedora-32-release
elif [ "$1" = Fedora-rawhide ]
then
  make -j "$(nproc)" --output-sync=recurse fedora-rawhide fedora-rawhide-release
elif [ "$1" = Ubuntu ]
then
  make -j "$(nproc)" --output-sync=recurse ubuntu ubuntu-cxx11 ubuntu-no-deprecated-code ubuntu-no-gmp-no-leda ubuntu-gcc6 ubuntu-gcc6-cxx1z ubuntu-gcc6-release ubuntu-gcc_master_cxx20-release
fi
docker images
