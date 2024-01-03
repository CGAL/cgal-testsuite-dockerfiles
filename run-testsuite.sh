#!/bin/bash
set -e

if [ -z "${CGAL_TESTER}" ]; then
    export CGAL_TESTER=$(whoami)
    echo 'CGAL_TESTER not set. Using `whoami`:'" $CGAL_TESTER"
fi

if [ -z "${CGAL_TEST_PLATFORM}" ]; then
    export CGAL_TEST_PLATFORM="${HOSTNAME}"
    echo "CGAL_TEST_PLATFORM not set. Using HOSTNAME: ${HOSTNAME}"
fi

# HACK: We depend on this line to easily extract the platform name
# from the logs.
echo "CGAL_TEST_PLATFORM=${CGAL_TEST_PLATFORM}"

if [ -z "${CGAL_NUMBER_OF_JOBS}" ]; then
    CGAL_NUMBER_OF_JOBS=1
    echo "CGAL_NUMBER_OF_JOBS not set. Defaulting to 1."
else
    echo "CGAL_NUMBER_OF_JOBS is ${CGAL_NUMBER_OF_JOBS}."
fi

declare -a "CGAL_CMAKE_FLAGS=${CGAL_CMAKE_FLAGS}"
echo "CGAL_CMAKE_FLAGS is ${CGAL_CMAKE_FLAGS[@]}."

# The directory where the release is stored.
export CGAL_RELEASE_DIR="/mnt/testsuite/"
# Directory where CGAL sources are stored.
CGAL_SRC_DIR="${CGAL_RELEASE_DIR}src/"
# Directory where CGAL tests are stored.
CGAL_TEST_DIR="${CGAL_RELEASE_DIR}test/"
# Directory where CGAL data are stored.
CGAL_DATA_DIR="${CGAL_RELEASE_DIR}data/"
# Directory where include/CGAL/version.h can be found.
CGAL_VERSION_DIR="${CGAL_RELEASE_DIR}"
if ! [ -f "${CGAL_VERSION_DIR}include/CGAL/version.h" ]; then
    CGAL_VERSION_DIR="${CGAL_RELEASE_DIR}Installation/"
fi
# Directory Testsuite (if branch build), or CGAL_RELEASE_DIR
CGAL_TESTSUITE_DIR="${CGAL_RELEASE_DIR}Testsuite/"
if ! [ -d "${CGAL_TESTSUITE_DIR}" ]; then
    CGAL_TESTSUITE_DIR="${CGAL_RELEASE_DIR}"
fi

# The directory where testresults are stored.
CGAL_TESTRESULTS="/mnt/testresults/"

CGAL_DIR="$HOME/build/src/cmake/platforms/${CGAL_TEST_PLATFORM}/"
# The directory where the release is built.
CGAL_SRC_BUILD_DIR="${CGAL_DIR}"
# The directory where the tests are built.
CGAL_TEST_BUILD_DIR="$HOME/build/src/cmake/platforms/${CGAL_TEST_PLATFORM}/test/"
PLATFORM="$CGAL_TEST_PLATFORM"

export CGAL_DIR
export CGAL_TEST_PLATFORM
export CGAL_DATA_DIR

# Create the binary directories
if [ ! -d "${CGAL_SRC_BUILD_DIR}" ]; then
    mkdir -p "${CGAL_SRC_BUILD_DIR}"
fi
if [ ! -d "${CGAL_TEST_BUILD_DIR}" ]; then
    mkdir -p "${CGAL_TEST_BUILD_DIR}"
fi

# Build CGAL. The CGAL_CMAKE_FLAGS used here will affect all other
# builds using this binary directory.

cd "${CGAL_SRC_BUILD_DIR}"
if [ -n "$DOCKERFILE_URL" ]; then
    echo "Docker image built from ${DOCKERFILE_URL}" | tee "${CGAL_TESTRESULTS}installation-${CGAL_TEST_PLATFORM}.log"
else
    echo "Docker container" > ${CGAL_TESTRESULTS}installation-${CGAL_TEST_PLATFORM}.log
fi

cmake ${INIT_FILE:+"-C${INIT_FILE}"} -DBUILD_TESTING=ON -DWITH_tests=ON -DCGAL_TEST_SUITE=ON $CGAL_RELEASE_DIR >${CGAL_TESTRESULTS}installation-${CGAL_TEST_PLATFORM}.log 2>&1 || :
rm CMakeCache.txt
CMAKE_OPTS="-DCGAL_TEST_SUITE=ON -DCMAKE_VERBOSE_MAKEFILE=ON -DWITH_tests=ON"
if [ -z "${SHOW_PROGRESS}" ]; then
  cmake ${INIT_FILE:+"-C${INIT_FILE}"} -DBUILD_TESTING=ON ${CMAKE_OPTS} $CGAL_RELEASE_DIR >${CGAL_TESTRESULTS}package_installation-${CGAL_TEST_PLATFORM}.log 2>&1 || :
else
  cmake ${INIT_FILE:+"-C${INIT_FILE}"} -DBUILD_TESTING=ON ${CMAKE_OPTS} $CGAL_RELEASE_DIR 2>&1 |tee ${CGAL_TESTRESULTS}package_installation-${CGAL_TEST_PLATFORM}.log || :
fi

LIST_TEST_FILE="${CGAL_TESTRESULTS}list_test_packages"
if [ -f ${LIST_TEST_FILE} ]; then
  LIST_TEST_PACKAGES=$(source ${LIST_TEST_FILE})
fi
INIT=""
for pkg in $LIST_TEST_PACKAGES; do
  if [ -z "$INIT" ]; then
    TO_TEST=$pkg
    INIT="y"
  else
    TO_TEST="${TO_TEST}|$pkg"
  fi
done
#unsets the limit of 1024 bits for the logs through ssh
echo "SET(CTEST_CUSTOM_MAXIMUM_PASSED_TEST_OUTPUT_SIZE 1000000000)" > CTestCustom.cmake
echo "SET(CTEST_CUSTOM_MAXIMUM_FAILED_TEST_OUTPUT_SIZE 1000000000)" >> CTestCustom.cmake
CTEST_OPTS="-T Start -T Test --timeout 1200 ${DO_NOT_TEST:+-E execution___of__}"
if [ -z "${SHOW_PROGRESS}" ]; then
    ctest ${TO_TEST:+-L ${TO_TEST} } ${CTEST_OPTS} -j${CGAL_NUMBER_OF_JOBS} ${KEEP_TESTS:+-FC .}>${CGAL_TESTRESULTS}ctest-${CGAL_TEST_PLATFORM}.log || :
else
    ctest ${TO_TEST:+-L ${TO_TEST} } ${CTEST_OPTS} -j${CGAL_NUMBER_OF_JOBS} ${KEEP_TESTS:+-FC .}|tee ${CGAL_TESTRESULTS}ctest-${CGAL_TEST_PLATFORM}.log || :
fi

TAG_DIR=$(awk '/^Create new tag: /{print $4F}' ${CGAL_TESTRESULTS}ctest-${CGAL_TEST_PLATFORM}.log)
cd Testing/${TAG_DIR}
RESULT_FILE=./"results_${CGAL_TESTER}_${PLATFORM}.txt"
rm -f "$RESULT_FILE"
touch "$RESULT_FILE"

sed -n '/The CXX compiler/s/-- The CXX compiler identification is/COMPILER_VERSION =/p' < "${CGAL_TESTRESULTS}installation-${CGAL_TEST_PLATFORM}.log" |sed -E "s/ = (.*)/\ = '\1\'/">> "$RESULT_FILE"
sed -n '/CGAL_VERSION /s/#define //p' < "${CGAL_VERSION_DIR}include/CGAL/version.h" >> "$RESULT_FILE"
echo "TESTER ${CGAL_TESTER}" >> "$RESULT_FILE"
echo "TESTER_NAME ${CGAL_TESTER_NAME}" >> "$RESULT_FILE"
echo "TESTER_ADDRESS ${CGAL_TESTER_ADDRESS}" >> "$RESULT_FILE"
echo "CGAL_TEST_PLATFORM ${PLATFORM}" >> "$RESULT_FILE"
grep -e "^-- USING " "${CGAL_TESTRESULTS}installation-${CGAL_TEST_PLATFORM}.log"|sort -u >> $RESULT_FILE
#Use sed to get the content of DEBUG or RELEASE CXX FLAGS so that Multiconfiguration platforms do provide their CXXXFLAGS to the testsuite page (that greps USING CXXFLAGS to get info)
sed -i -E 's/(^-- USING )(DEBUG|RELEASE) (CXXFLAGS)/\1\3/' $RESULT_FILE
echo "------------" >> "$RESULT_FILE"
touch ../../../../../.scm-branch
if [ -f /mnt/testsuite/.scm-branch ]; then
    cat /mnt/testsuite/.scm-branch >> ../../../../../.scm-branch
fi
python3 ${CGAL_TESTSUITE_DIR}test/parse-ctest-dashboard-xml.py $CGAL_TESTER $PLATFORM

for file in $(ls|grep _Tests); do
  mv $file "$(echo "$file" | sed 's/_Tests//g')"
done
OUTPUT_FILE=results_${CGAL_TESTER}_${PLATFORM}.tar
TEST_REPORT="TestReport_${CGAL_TESTER}_${PLATFORM}"
mkdir -p Installation
chmod 777 Installation
cat "${CGAL_TESTRESULTS}package_installation-${CGAL_TEST_PLATFORM}.log" >> "Installation/${TEST_REPORT}"

#call the python script to complete the results report.
python3 ${CGAL_TESTSUITE_DIR}test/post_process_ctest_results.py Installation/${TEST_REPORT} ${TEST_REPORT} results_${CGAL_TESTER}_${PLATFORM}.txt
rm -f $OUTPUT_FILE $OUTPUT_FILE.gz
rm ../../../../../.scm-branch
tar cf $OUTPUT_FILE results_${CGAL_TESTER}_${PLATFORM}.txt */"$TEST_REPORT"
echo
gzip -9f $OUTPUT_FILE
cp "${OUTPUT_FILE}.gz" "results_${CGAL_TESTER}_${PLATFORM}.txt" "${CGAL_TESTRESULTS}"
