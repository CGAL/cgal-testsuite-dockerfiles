#!/bin/bash

case $(pacman -Q cmake) in
    "cmake 3.6.3"*) cd /usr/share/cmake-3.6/Modules; [ -e FindBoost.cmake.orig ] || patch -p2 < <(cat /updates/*.patch);;
esac
