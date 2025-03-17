#!/bin/bash

set -e

# Download and install LAStools
wget https://github.com/LAStools/LAStools/archive/refs/heads/master.zip
unzip master.zip
cd LAStools-master

mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j "$(nproc)" VERBOSE=1
make install
cd ../..
rm -rf LAStools-master master.zip
