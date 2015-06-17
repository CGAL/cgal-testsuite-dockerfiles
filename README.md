cgal-testsuite-dockerfiles
==========================

Dockerfiles and tools to run the CGAL testsuite inside containers.

It is recommended to get the images directly from Docker Hub instead
of building them locally:

    docker pull --all cgal/testsuite-docker # get all images
    docker pull cgal/testsuite-docker:TAG # get a specific image by replacing TAG with some tag

A list of available tags can [be found here](https://registry.hub.docker.com/u/cgal/testsuite-docker/tags/manage/).

Building Images locally
-----------------------

To build images locally see the help of `build_images.py`.

Running the testsuite
---------------------

To run the testsuite using this image:

    ./test_cgal.py --username **** --passwd **** --images cgal-testsuite/centos6

If you would like to use an already extraced internal release:

    ./test_cgal.py --use-local --testsuite /path/to/release --images cgal-testsuite/centos6

It is also possible to only test specific packages, but keep in mind that this will alter the release:

    ./test_cgal.py --use-local --testsuite /path/to/release --images cgal-testsuite/centos6 \
                   --packages Core Mesh_2 Mesh_3


Default Arguments
-----------------

Default arguments can be provided through a `test_cgal_rc` file in
`$XDG_CONFIG_HOME` (typically `$HOME/.config`) or the config directory
of the resource `CGAL`.

Cron Job
--------

To set up a machine for submission of the whole testsuite via a
cronjob the following configuration could be used:

    --user xxxxxxx
    --passwd xxxxxx
    --force-rm
    --upload-results
    --tester-name="My Name"
    --tester-address joe@example.com
    --testsuite /path/to/testsuite
    --testresults /path/to/testresults
    --images docker.io/cgal/testsuite-docker:centos5
             docker.io/cgal/testsuite-docker:centos6
             docker.io/cgal/testsuite-docker:archlinux

The names of the images depend on how they have been obtained. The
example shows the names that will typically be used when obtaining the
images through Docker Hub.

Modifying the build environment
-------------------------------

To run a testsuite in a specific environment (specific version of some
library), set up a Docker image that provides that environment. Don't
forget to make sure your installed library is preferred by CMake over
the system library by setting appropriate environment variables.

To control how the testsuite is being build use the environment
variable `CGAL_CMAKE_FLAGS` to change the CMake invocation. This
variable must look like an declaration where each array element
contains one command line argument of the cmake call, e.g.

    ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-std=c++11 -Wextra\" \"-DCMAKE_CXX_FLAGS=-fno-asm\")"

You can also change default build variables through the classic
environment variables (e.g. `LD_FLAGS`, `CXX_FLAGS`).

Required Non-Standard Python Packages
------------------------

The code requires several non-standard python2 packages, which are
available in all common distributions.

- `docker-py`
- `xdg`

SELinux issues
--------------
On Linux system using SELinux (such as the default setting for the recent
versions of Fedora, RHEL, and CentOS), you might need to relabel the host
files and directories used as volumes by the containers:

    chcon -Rt svirt_sandbox_file_t ./docker-entrypoint.sh ./testsuite ./testresults

If you use the options `--testsuite /path/to/testsuite` or `--testresults /path/to/testresults`, then the pointed directories must also be relabeled with `svirt_sandbox_file_t`:

    chcon -Rt svirt_sandbox_file_t /path/to/testresults /path/to/testresults
