SET(CMAKE_CXX_FLAGS "-Wall -frounding-math -Wno-dangling-reference -Wno-maybe-uninitialized -msse3 -fsanitize=address" CACHE STRING "")
SET(CMAKE_CXX_FLAGS_DEBUG "" CACHE STRING "")
SET(CMAKE_CXX_FLAGS_RELEASE "-DCGAL_NDEBUG -O3" CACHE STRING "")
SET(CMAKE_BUILD_TYPE "Release" CACHE STRING "")
