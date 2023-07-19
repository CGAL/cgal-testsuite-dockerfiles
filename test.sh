#!/bin/bash

set -e

curl -o cgal.tar.gz  -L $(curl -s https://api.github.com/repos/CGAL/cgal/releases/latest | jq -r .tarball_url)
mkdir -p cgal
tar -xzf cgal.tar.gz -C cgal --strip-components=1

if command -v selinuxenabled >/dev/null && selinuxenabled; then
  chcon -Rt container_file_t cgal
fi

if [ -n "$GITHUB_SHA" ]; then
  COMMIT_URL=https://github.com/${GITHUB_REPOSITORY}/blob/${GITHUB_SHA}
fi

function dockerbuild() {
  if [ -z "$GITHUB_SHA" ]; then
    docker build -t cgal/testsuite-docker:$1 ./$2
  else
    docker build --build-arg dockerfile_url=${COMMIT_URL}/$2/Dockerfile -t cgal/testsuite-docker:$1 ./$2
  fi
}

function dockerbuildandtest() {
  dockerbuild $1 $2
  docker run --rm -v $PWD/cgal:/cgal cgal/testsuite-docker:$1 bash -c 'cmake -DWITH_examples=ON /cgal && cmake --build . -t terrain'
  if command -v python3 >/dev/null; then
    python3 ./test_container/test_container.py --image cgal/testsuite-docker:$1 --cgal-dir $HOME/cgal
  fi
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
elif [ "$1" = CentOS-5 ]
then
  dockerbuildandtest centos5 CentOS-5
elif [ "$1" = CentOS-6 ]
then
  dockerbuildandtest centos6 CentOS-6
  dockerbuildandtest centos6-cxx11-boost157 CentOS-6-CXX11-Boost157
elif [ "$1" = CentOS-6-32 ]
then
  dockerbuildandtest centos6-32 CentOS-6-32
elif [ "$1" = CentOS-7-ICC-beta ]
then
    if [ -z "$ICC_BETA_ACTIVATION_SERIAL_NUMBER" -a -n "$TRAVIS_PULL_REQUEST" ]; then
        echo "The build of this image is deactivated in pull-requests"
    else
        echo ACTIVATION_SERIAL_NUMBER=$ICC_BETA_ACTIVATION_SERIAL_NUMBER > secret.file
        # Trick to share the secret with the building container, without
        # having the secret appear in the history of the built image:
        # transmit the secret at built time by http.
        docker network inspect local || docker network create local
        docker run --network local --name web -v $PWD/secret.file:/usr/share/nginx/html/index.html -d nginx
        docker build --network local -t cgal/testsuite-docker:centos7-icc-beta ./CentOS-7-ICC-beta
    fi
elif [ "$1" = CentOS-7-ICC ]
then
  dockerbuildandtest centos7-icc CentOS-7-ICC
elif [ "$1" = CentOS-7 ]
then
  dockerbuildandtest centos7 CentOS-7
  dockerbuildandtest centos7-release CentOS-7-Release
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
elif [ "$1" = Ubuntu-GCC-master ]
then
  dockerbuildandtest ubuntu-gcc6 Ubuntu-GCC6
  dockerbuildandtest ubuntu-gcc6-cxx1z Ubuntu-GCC6-CXX1Z
  dockerbuildandtest ubuntu-gcc6-release Ubuntu-GCC6-Release
  dockerbuildandtest ubuntu-gcc_master_cxx20-release Ubuntu-GCC_master_cpp20-Release
fi
docker images
