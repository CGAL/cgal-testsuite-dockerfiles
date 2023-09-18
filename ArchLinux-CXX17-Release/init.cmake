SET(CMAKE_CXX_FLAGS "-Wall -frounding-math -Wno-dangling-reference -Wno-maybe-uninitialized" CACHE STRING "")
SET(CMAKE_CXX_FLAGS_DEBUG "" CACHE STRING "")
SET(CMAKE_CXX_FLAGS_RELEASE "-Wall -O3 -msse4.1 -std=gnu++17" CACHE STRING "")
SET(CMAKE_BUILD_TYPE "Release" CACHE STRING "")
