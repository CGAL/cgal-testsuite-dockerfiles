#!/bin/bash

set -e

[ -n "$ACTIONS_RUNNER_DEBUG" ] && set -x

CGAL_TARBALL=$(curl -s https://api.github.com/repos/CGAL/cgal/releases/latest | jq -r .tarball_url)
echo "::group::Download and extract CGAL tarball from $CGAL_TARBALL"
curl -o cgal.tar.gz  -L "$CGAL_TARBALL"
mkdir -p cgal
tar -xzf cgal.tar.gz -C cgal --strip-components=1
if command -v selinuxenabled >/dev/null && selinuxenabled; then
  chcon -Rt container_file_t cgal
fi
echo '::endgroup::'

echo "::group::Install docker-py"
if command -v python3 >/dev/null; then
  python3 -m pip install docker
fi
echo '::endgroup::'

if [ -n "$GITHUB_SHA" ]; then
  COMMIT_URL=https://github.com/${GITHUB_REPOSITORY}/blob/${GITHUB_SHA}
fi

function dockerbuild() {
  if [ -z "$COMMIT_URL" ]; then
    docker build -t cgal/testsuite-docker:$1 ./$2
  else
    docker build --build-arg dockerfile_url=${COMMIT_URL}/$2/Dockerfile -t cgal/testsuite-docker:$1 ./$2
  fi
}

function dockerbuildandtest() {
  echo "::group::Build image $1 from $2/Dockerfile"
  dockerbuild $1 $2
  echo '::endgroup::'

  echo "::group::Test image $1"
  docker run --rm -v $PWD/cgal:/cgal cgal/testsuite-docker:$1 bash -c 'cmake -DWITH_examples=ON -S /cgal -B /build && cmake --build /build -t terrain -v'
  if command -v python3 >/dev/null; then
    python3 ./test_container/test_container.py --image cgal/testsuite-docker:$1 --cgal-dir $HOME/cgal
  fi
  echo '::endgroup::'
}

if [ "$1" = ArchLinux ]
then
  dockerbuildandtest archlinux ArchLinux
  dockerbuildandtest archlinux-cxx14 ArchLinux-CXX14
  dockerbuildandtest archlinux-cxx17-release ArchLinux-CXX17-Release
  dockerbuildandtest archlinux-clang ArchLinux-clang
  dockerbuildandtest archlinux-clang-cxx14 ArchLinux-clang-CXX14
  dockerbuildandtest archlinux-clang-cxx17-release ArchLinux-clang-CXX17-Release
  dockerbuildandtest archlinux-clang-cxx20-release ArchLinux-clang-CXX20-Release
  dockerbuildandtest archlinux-clang-release ArchLinux-clang-Release
elif [ "$1" = Debian-stable ]
then
  dockerbuildandtest debian-stable Debian-stable
  dockerbuildandtest debian-stable-release Debian-stable-Release
  dockerbuildandtest debian-stable-cross-compilation-for-arm Debian-stable-cross-compilation-for-arm
elif [ "$1" = Debian-testing ]
then
  dockerbuildandtest debian-testing Debian-testing
  dockerbuildandtest debian-testing-clang-main Debian-testing-clang-main
elif [ "$1" = Fedora ]
then
  dockerbuildandtest fedora Fedora
  dockerbuildandtest fedora-with-leda Fedora-with-LEDA
  dockerbuildandtest fedora-release Fedora-Release
  dockerbuildandtest fedora-strict-ansi Fedora-strict-ansi
elif [ "$1" = Fedora-32 ]
then
  dockerbuildandtest fedora-32 Fedora-32
  dockerbuildandtest fedora-32-release Fedora-32-Release
elif [ "$1" = Fedora-rawhide ]
then
  dockerbuildandtest fedora-rawhide Fedora-rawhide
  dockerbuildandtest fedora-rawhide-release Fedora-rawhide-Release
elif [ "$1" = Ubuntu ]
then
  dockerbuildandtest ubuntu Ubuntu
  dockerbuildandtest ubuntu-cxx11 Ubuntu-CXX11
  dockerbuildandtest ubuntu-no-deprecated-code Ubuntu-NO_DEPRECATED_CODE
  dockerbuildandtest ubuntu-no-gmp-no-leda Ubuntu-no-gmp-no-leda
  dockerbuildandtest ubuntu-gcc6 Ubuntu-GCC6
  dockerbuildandtest ubuntu-gcc6-cxx1z Ubuntu-GCC6-CXX1Z
  dockerbuildandtest ubuntu-gcc6-release Ubuntu-GCC6-Release
  dockerbuildandtest ubuntu-gcc_master_cxx20-release Ubuntu-GCC_master_cpp20-Release
fi
docker images
