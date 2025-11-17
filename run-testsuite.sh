#!/bin/bash

# prompt for the xtrace output
PS4='+ $(date "+%Y-%m-%d %H:%M:%S") ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
# use a new fd (chosen by bash) to redirect the xtrace output
exec {fd}>&2
BASH_XTRACEFD=${fd}
unset fd

set -e

if [ -z "${CGAL_TESTER}" ]; then
    export CGAL_TESTER=$(whoami)
    echo 'CGAL_TESTER not set. Using `whoami`:'" $CGAL_TESTER"
fi

if [ -z "${CGAL_TEST_PLATFORM}" ]; then
    export CGAL_TEST_PLATFORM="${HOSTNAME}"
    echo "CGAL_TEST_PLATFORM not set. Using HOSTNAME: ${HOSTNAME}"
fi

echo "CGAL_TEST_PLATFORM=${CGAL_TEST_PLATFORM}"

if [ -z "${CGAL_NUMBER_OF_JOBS}" ]; then
    CGAL_NUMBER_OF_JOBS=1
    echo "CGAL_NUMBER_OF_JOBS not set. Defaulting to 1."
else
    echo "CGAL_NUMBER_OF_JOBS is ${CGAL_NUMBER_OF_JOBS}."
fi

# The directory where the release is stored.
export CGAL_RELEASE_DIR="/mnt/testsuite"
# Directory where CGAL sources are stored.
CGAL_SRC_DIR="${CGAL_RELEASE_DIR}/src"
# Directory where CGAL tests are stored.
CGAL_TEST_DIR="${CGAL_RELEASE_DIR}/test"
# Directory where CGAL data are stored.
CGAL_DATA_DIR="${CGAL_RELEASE_DIR}/data"
# Directory where include/CGAL/version.h can be found.
CGAL_VERSION_DIR="${CGAL_RELEASE_DIR}"
if ! [ -f "${CGAL_VERSION_DIR}/include/CGAL/version.h" ]; then
    CGAL_VERSION_DIR="${CGAL_RELEASE_DIR}/Installation"
fi
# Directory Testsuite (if branch build), or CGAL_RELEASE_DIR
CGAL_TESTSUITE_DIR="${CGAL_RELEASE_DIR}/Testsuite"
if ! [ -d "${CGAL_TESTSUITE_DIR}" ]; then
    CGAL_TESTSUITE_DIR="${CGAL_RELEASE_DIR}"
fi

# The directory where testresults are stored.
CGAL_TESTRESULTS="/mnt/testresults"

CGAL_DIR="$HOME/build/src/cmake/platforms/${CGAL_TEST_PLATFORM}"
# The directory where the release is built.
CGAL_SRC_BUILD_DIR="${CGAL_DIR}"
# The directory where the tests are built.
CGAL_TEST_BUILD_DIR="$HOME/build/src/cmake/platforms/${CGAL_TEST_PLATFORM}/test"
PLATFORM="$CGAL_TEST_PLATFORM"

export CGAL_DIR
export CGAL_TEST_PLATFORM
export CGAL_DATA_DIR

# If the option xtrace (`set -x`) is not set,
# then set it, and redirect all trace output to a log file.
BASH_LOG_FILE=${CGAL_TESTRESULTS}/bash-xtrace-${CGAL_TEST_PLATFORM}.log
case "$-" in
  *x*) ;;
  *) echo "Redirecting xtrace output to ${BASH_LOG_FILE}"; eval "exec ${BASH_XTRACEFD}>${BASH_LOG_FILE}"; set -x ;;
esac

# Create the binary directories
if [ ! -d "${CGAL_SRC_BUILD_DIR}" ]; then
    mkdir -p "${CGAL_SRC_BUILD_DIR}"
fi
if [ ! -d "${CGAL_TEST_BUILD_DIR}" ]; then
    mkdir -p "${CGAL_TEST_BUILD_DIR}"
fi

CMAKE_LOG_FILE=${CGAL_TESTRESULTS}/cmake-${CGAL_TEST_PLATFORM}.log
CTEST_LOG_FILE=${CGAL_TESTRESULTS}/ctest-${CGAL_TEST_PLATFORM}.log

rm -f "${CMAKE_LOG_FILE}" "${CTEST_LOG_FILE}"

REDIRECT_TO() {
  exec 3>&1 4>&2
  if [ -z "${SHOW_PROGRESS}" ]; then
    echo "Redirecting stdout and stderr to $1"
    exec > "$1" 2>&1
  else
    exec > >(tee ${1}) 2>&1
  fi
  _REDIRECTED=1
}

REVERT_REDIRECTIONS() {
  [ -z "$_REDIRECTED" ] && return
  exec 1>&3 3>&- 2>&4 4>&-
  [ -z "${SHOW_PROGRESS}" ] && echo "Reverting redirections of stdout and stderr"
  unset _REDIRECTED
}

cd "${CGAL_SRC_BUILD_DIR}"

REDIRECT_TO "${CMAKE_LOG_FILE}"

if [ -n "$DOCKERFILE_URL" ]; then
    echo "Docker image built from ${DOCKERFILE_URL}"
fi
echo "Docker container running image ${IMAGE_TAG}"

# Configure CGAL.
cmake ${INIT_FILE:+"-C${INIT_FILE}"} -DBUILD_TESTING=ON -DCGAL_TEST_SUITE=ON -DCMAKE_VERBOSE_MAKEFILE=ON -DWITH_tests=ON "$CGAL_RELEASE_DIR" || _CMAKE_ERROR=$?

REVERT_REDIRECTIONS

LIST_TEST_FILE="${CGAL_TESTRESULTS}/list_test_packages"
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

# unset the limits of 1 KiB for the logs and set them to 1 GB instead
cat <<EOF > CTestCustom.cmake
set(CTEST_CUSTOM_MAXIMUM_PASSED_TEST_OUTPUT_SIZE 1000000000)
set(CTEST_CUSTOM_MAXIMUM_FAILED_TEST_OUTPUT_SIZE 1000000000)
EOF

# add a configuration file for the tests (required since CMake-3.32)
cat <<EOF > CTestConfiguration.ini
SourceDirectory: ${CGAL_RELEASE_DIR}
BuildDirectory: ${CGAL_SRC_BUILD_DIR}
EOF

CTEST_OPTS="-T Start -T Test --timeout 1200 ${DO_NOT_TEST:+-E execution___of__}"

if [ -z "${_CMAKE_ERROR}" ]; then
  REDIRECT_TO "${CTEST_LOG_FILE}"
  ctest ${TO_TEST:+-L ${TO_TEST} } ${CTEST_OPTS} -j${CGAL_NUMBER_OF_JOBS} ${KEEP_TESTS:+-FC .} || true
  REVERT_REDIRECTIONS
  TAG_DIR=$(awk '/tag: /{print $4F}' "${CTEST_LOG_FILE}")
else
  TAG_DIR="error"
  mkdir -p Testing/${TAG_DIR}
fi

cd Testing/${TAG_DIR}
RESULT_FILE=results_${CGAL_TESTER}_${PLATFORM}.txt
rm -f ./"$RESULT_FILE"
touch "$RESULT_FILE"

sed -n '/The CXX compiler/s/-- The CXX compiler identification is/COMPILER_VERSION =/p' < "${CMAKE_LOG_FILE}" |sed -E "s/ = (.*)/\ = '\1\'/">> "$RESULT_FILE"
sed -n '/CGAL_VERSION /s/#define //p' < "${CGAL_VERSION_DIR}/include/CGAL/version.h" >> "$RESULT_FILE"
echo "CGAL_SUMMARY_NAME ${CGAL_SUMMARY_NAME:-$CGAL_TEST_PLATFORM}" >> "$RESULT_FILE"
echo "TESTER ${CGAL_TESTER}" >> "$RESULT_FILE"
echo "TESTER_NAME ${CGAL_TESTER_NAME}" >> "$RESULT_FILE"
echo "TESTER_ADDRESS ${CGAL_TESTER_ADDRESS}" >> "$RESULT_FILE"
echo "CGAL_TEST_PLATFORM ${PLATFORM}" >> "$RESULT_FILE"
grep -e "^-- Operating system: " "${CMAKE_LOG_FILE}"|sort -u >> "$RESULT_FILE"
grep -e "^-- USING " "${CMAKE_LOG_FILE}"|sort -u >> "$RESULT_FILE"
sed -n '/^-- Third-party library /p' "${CMAKE_LOG_FILE}" >> "$RESULT_FILE"
# Use sed to get the content of DEBUG or RELEASE CXX FLAGS so that Multi-config platforms do provide their CXXFLAGS to the testsuite page (that greps USING CXXFLAGS to get info)
sed -i -E 's/(^-- USING )(DEBUG|RELEASE) (CXXFLAGS)/\1\3/' "$RESULT_FILE"
echo "------------" >> "$RESULT_FILE"
touch ../../../../../.scm-branch
if [ -f /mnt/testsuite/.scm-branch ]; then
    cat /mnt/testsuite/.scm-branch >> ../../../../../.scm-branch
fi
if [ -z "${_CMAKE_ERROR}" ]; then
  python3 "${CGAL_TESTSUITE_DIR}/test/parse-ctest-dashboard-xml.py" "$CGAL_TESTER" "$PLATFORM"
fi

for file in $(ls|grep _Tests); do
  mv $file "$(echo "$file" | sed 's/_Tests//g')"
done
OUTPUT_FILE=results_${CGAL_TESTER}_${PLATFORM}.tar
TEST_REPORT="TestReport_${CGAL_TESTER}_${PLATFORM}"
mkdir -p Installation
chmod 777 Installation
cat "${CMAKE_LOG_FILE}" >> "Installation/${TEST_REPORT}"

#call the python script to complete the results report.
if [ -z "${_CMAKE_ERROR}" ]; then
  python3 "${CGAL_TESTSUITE_DIR}/test/post_process_ctest_results.py" "Installation/${TEST_REPORT}" "${TEST_REPORT}" "$RESULT_FILE"
else
  REDIRECT_TO "Installation/${TEST_REPORT}"
  printf "CMake configuration failed\n\nHere is the CMake log:\n\n"
  cat "${CMAKE_LOG_FILE}"
  printf "\n-----------------------\nHere is the Bash log:\n\n"
  cat "${BASH_LOG_FILE}"
  REVERT_REDIRECTIONS
fi
rm -f ./"$OUTPUT_FILE" ./"$OUTPUT_FILE.gz"
rm ../../../../../.scm-branch
tar cf $OUTPUT_FILE "$RESULT_FILE" */"$TEST_REPORT"
echo
gzip -9f $OUTPUT_FILE
mv "${OUTPUT_FILE}.gz" "$RESULT_FILE" "${CGAL_TESTRESULTS}/"
