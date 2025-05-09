cgal-testsuite-dockerfiles
==========================

Dockerfiles and tools to run the CGAL testsuite inside containers.

It is recommended to get the images directly from Docker Hub instead
of building them locally:

    docker pull --all-tags cgal/testsuite-docker # get all images
    docker pull cgal/testsuite-docker:TAG # get a specific image by replacing TAG with some tag

A list of available tags can [be found here](https://hub.docker.com/r/cgal/testsuite-docker/tags).

Building Images locally
-----------------------

To build images locally see the help of `build_images.py`.

Running the testsuite
---------------------

To run the testsuite using this image:

    ./test_cgal.py --user **** --passwd **** --images cgal-testsuite/centos6

If you would like to use an already extraced internal release:

    ./test_cgal.py --use-local --testsuite /path/to/release --images cgal-testsuite/centos6

It is also possible to only test specific packages, but keep in mind that this will alter the release:

    ./test_cgal.py --use-local --testsuite /path/to/release --images cgal-testsuite/centos6 \
                   --packages Core Mesh_2 Mesh_3


Running the testsuite for one container
---------------------------------------

Use a command similar to that one:

    docker run --rm -t -i -v $HOME/Git/cgal-master:/mnt/testsuite:ro,z -v $PWD/docker-entrypoint.sh:/mnt/testsuite/docker-entrypoint.sh:ro,z -v $PWD/run-testsuite.sh:/mnt/testsuite/run-testsuite.sh:z -v $PWD/testresults:/mnt/testresults:z cgal/testsuite-docker:debian-testing bash /mnt/testsuite/docker-entrypoint.sh

If you want a limited testsuite, you can have a file `testresults/list_test_packages` containing something like:

    echo Mesh_2
    echo Triangulation_2

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
    --images cgal/testsuite-docker:centos5
             cgal/testsuite-docker:centos6
             cgal/testsuite-docker:archlinux

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

- `docker`
- `xdg`

They can be installed using `pip`:

    pip install docker xdg

SELinux issues
--------------
On Linux system using SELinux (such as the default setting for the recent
versions of Fedora, RHEL, and CentOS), you might need to relabel the host
files and directories used as volumes by the containers:

    chcon -Rt svirt_sandbox_file_t ./docker-entrypoint.sh ./testsuite ./testresults

If you use the options `--testsuite /path/to/testsuite` or `--testresults /path/to/testresults`, then the pointed directories must also be relabeled with `svirt_sandbox_file_t`:

    chcon -Rt svirt_sandbox_file_t /path/to/testresults /path/to/testresults
