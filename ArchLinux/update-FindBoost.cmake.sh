#!/bin/bash

case $(pacman -Q cmake) in
    "cmake 3.6.3"*) [ -e /usr/share/cmake-3.6/Modules/FindBoost.cmake.orig ] || (cd /usr/share/cmake-3.6/Modules && patch -p2 < <(cat /updates/*.patch) );;
esac
