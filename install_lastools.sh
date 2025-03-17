#!/bin/bash

set -e

# Download and install LAStools
wget https://github.com/LAStools/LAStools/archive/refs/heads/master.zip
unzip master.zip
cd LAStools-master

patch -p1 <<'EOF'
diff --git a/CMakeLists.txt b/CMakeLists.txt
index e10d12c..2fcbdcf 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -1,4 +1,4 @@
-cmake_minimum_required(VERSION 3.1 FATAL_ERROR)
+cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
 set(CMAKE_SUPPRESS_REGENERATION true)
 set(CMAKE_CXX_STANDARD 17)
 if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
diff --git a/LASlib/CMakeLists.txt b/LASlib/CMakeLists.txt
index 495ee5b..e41cb32 100644
--- a/LASlib/CMakeLists.txt
+++ b/LASlib/CMakeLists.txt
@@ -1,4 +1,4 @@
-cmake_minimum_required(VERSION 3.1 FATAL_ERROR)
+cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
 set(CMAKE_SUPPRESS_REGENERATION true)
 project("LASlib")
 if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
diff --git a/LASzip/src/mydefs.cpp b/LASzip/src/mydefs.cpp
index fff8694..9d923a6 100644
--- a/LASzip/src/mydefs.cpp
+++ b/LASzip/src/mydefs.cpp
@@ -33,6 +33,7 @@
 #include "lasmessage.hpp"
 #include "laszip_common.h"

+#include <algorithm>
 #include <cstring>
 #include <filesystem>
 #include <stdarg.h>
EOF

mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j "$(nproc)"
make install
cd ../..
rm -rf LAStools-master master.zip
