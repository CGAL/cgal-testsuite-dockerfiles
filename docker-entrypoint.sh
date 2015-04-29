#!/bin/bash
# This script is the entrypoint of a CGAL testsuite docker container.
set -e

# The directory where the release is stored.
CGAL_RELEASE_DIR="/mnt/testsuite/"
# Directory where CGAL sources are stored.
CGAL_SRC_DIR="${CGAL_RELEASE_DIR}src/"
# Directory where CGAL tests are stored.
CGAL_TEST_DIR="${CGAL_RELEASE_DIR}test/"

# The directory where testresults are stored.
CGAL_TESTRESULTS="/mnt/testresults/"
# The actual logfile.
CGAL_LOG_FILE="${CGAL_TESTRESULTS}${CGAL_TEST_PLATFORM}.log"

# The directory of the build tree.
CGAL_DIR="/build/src"
CGAL_SRC_BUILD_DIR="${CGAL_DIR}"
CGAL_TEST_BUILD_DIR="/build/test"
CGAL_DEMO_BUILD_DIR="/build/demo"

export CGAL_DIR

# Create the binary directories
if [ ! -d "$CGAL_SRC_BUILD_DIR" ]; then 
    mkdir -p "$CGAL_SRC_BUILD_DIR"
fi
if [ ! -d "$CGAL_TEST_BUILD_DIR" ]; then
    mkdir -p "$CGAL_TEST_BUILD_DIR"
fi
if [ ! -d "$CGAL_SRC_BUILD_DIR" ]; then
    mkdir - "$CGAL_SRC_BUILD_DIR"
fi


# Build CGAL
cd "$CGAL_SRC_BUILD_DIR"
cmake -DRUNNING_CGAL_AUTO_TEST=TRUE VERBOSE=1 "$CGAL_RELEASE_DIR" 2>&1 | tee "$CGAL_LOG_FILE"
make VERBOSE=ON -k -fMakefile 2>&1 | tee -a "$CGAL_LOG_FILE"

# Build and Execute the Tests

# We need to make a copy of the whole test dir because the current
# scripts don't allow out of source builds.
cp -r "${CGAL_TEST_DIR}/." "$CGAL_TEST_BUILD_DIR"
cd "$CGAL_TEST_BUILD_DIR"
make -k -fmakefile2
