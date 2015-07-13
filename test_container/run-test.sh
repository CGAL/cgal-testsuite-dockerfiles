#!/bin/bash -l

mkdir /cgal_test && cd /cgal_test
cp /mnt/test/CMakeLists.txt .
cmake .
