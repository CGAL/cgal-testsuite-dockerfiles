# cgal-testsuite-dockerfiles

Dockerfiles and tools to run the CGAL testsuite inside containers.

## Quick Start

Each Dockerfile has **two build targets**:

- `cgal-base` — Standard CGAL testsuite image
- `cgal-toolbox` — Toolbox-compatible variant (for containers/toolbox)

### Build in 3 Steps

```bash
# 1. Make build script executable
chmod +x build.sh

# 2. Build both variants
./build.sh debian-stable

# 3. Use them
docker run -it localhost/cgal/testsuite:debian-stable bash
toolbox create --image localhost/cgal/testsuite:debian-stable-toolbox
toolbox enter
```

See `./build.sh --help` for all options:

```bash
./build.sh --all              # Build all distributions
./build.sh --std-only         # Standard images only
./build.sh --push --registry  # Push to registry
```

## Getting Pre-built Images

It is recommended to get the images directly from Docker Hub instead
of building them locally:

```shell
    docker pull --all-tags cgal/testsuite-docker # get all images
    docker pull cgal/testsuite-docker:TAG # get a specific image by replacing TAG with some tag
```

A list of available tags can [be found here](https://hub.docker.com/r/cgal/testsuite-docker/tags).

## Building Images Locally

Use the build script:

```bash
    ./build.sh debian-stable
```

Or manually with Docker:

```bash
    docker build --build-context root=. --target cgal-base -t cgal/testsuite:debian-stable Debian-stable/
    docker build --build-context root=. --target cgal-toolbox -t cgal/testsuite:debian-stable-toolbox Debian-stable/
```

The `root=.` named build context is required because some Dockerfiles copy files from the repository root.

To test each standard image after building it, use a local CGAL source tree:

```bash
    CGAL_SOURCE_DIR=/path/to/cgal ./build.sh debian-stable --test
```

`CGAL_SOURCE_DIR` defaults to `./cgal`. The test runs the CI CMake
configuration and builds the `terrain` example inside the image. Toolbox
images are built as usual but are not tested by this option. A failed test
makes the command fail and prevents that image from being pushed with `--push`.
On SELinux systems, the source directory must be accessible to containers; see
the SELinux section below.

## Checking the Toolbx Requirements

`check-toolbox.sh` verifies that toolbox images satisfy the
[Toolbx image requirements](https://containertoolbx.org/doc/#requirements):

```bash
    ./check-toolbox.sh localhost/cgal/testsuite:debian-stable-toolbox
```

`MUST` requirements are reported as `FAIL` and make the script exit with a
non-zero status; `SHOULD` recommendations are reported as `WARN` (use
`--strict` to treat them as failures). The script is run in the CI for each
toolbox variant. It uses `docker`, or `podman` if `docker` is not installed
(override with `CONTAINER_ENGINE`).

## Running the testsuite

To run the testsuite using this image:

```bash
    ./test_cgal.py --user **** --passwd **** --images cgal-testsuite/centos6
```

If you would like to use an already extraced internal release:

```bash
    ./test_cgal.py --use-local --testsuite /path/to/release --images cgal-testsuite/centos6
```

It is also possible to only test specific packages, but keep in mind that this will alter the release:

```bash
    ./test_cgal.py --use-local --testsuite /path/to/release --images cgal-testsuite/centos6 \
                   --packages Core Mesh_2 Mesh_3
```

## Running the testsuite for one container

Use a command similar to that one:

```bash
    docker run --rm -t -i -v $HOME/Git/cgal-master:/mnt/testsuite:ro,z -v $PWD/docker-entrypoint.sh:/mnt/testsuite/docker-entrypoint.sh:ro,z -v $PWD/run-testsuite.sh:/mnt/testsuite/run-testsuite.sh:z -v $PWD/testresults:/mnt/testresults:z cgal/testsuite-docker:debian-testing bash /mnt/testsuite/docker-entrypoint.sh
```

If you want a limited testsuite, you can have a file `testresults/list_test_packages` containing something like:

```bash
    echo Mesh_2
    echo Triangulation_2
```

## Default Arguments

Default arguments can be provided through a `test_cgal_rc` file in
`$XDG_CONFIG_HOME` (typically `$HOME/.config`) or the config directory
of the resource `CGAL`.

## Cron Job

To set up a machine for submission of the whole testsuite via a
cronjob the following configuration could be used:

```plain
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
```

The names of the images depend on how they have been obtained. The
example shows the names that will typically be used when obtaining the
images through Docker Hub.

## Modifying the build environment

To run a testsuite in a specific environment (specific version of some
library), set up a Docker image that provides that environment. Don't
forget to make sure your installed library is preferred by CMake over
the system library by setting appropriate environment variables.

To control how the testsuite is being build use the environment
variable `CGAL_CMAKE_FLAGS` to change the CMake invocation. This
variable must look like an declaration where each array element
contains one command line argument of the cmake call, e.g.

```Dockerfile
    ENV CGAL_CMAKE_FLAGS="(\"-DCGAL_CXX_FLAGS=-std=c++11 -Wextra\" \"-DCMAKE_CXX_FLAGS=-fno-asm\")"
```

You can also change default build variables through the classic
environment variables (e.g. `LD_FLAGS`, `CXX_FLAGS`).

## Required Non-Standard Python Packages

The code requires several non-standard python2 packages, which are
available in all common distributions.

- `docker`
- `xdg`

They can be installed using `pip`:

```bash
    pip install docker xdg
```

## SELinux issues

On Linux system using SELinux (such as the default setting for the recent
versions of Fedora, RHEL, and CentOS), you might need to relabel the host
files and directories used as volumes by the containers:

```bash
    chcon -Rt svirt_sandbox_file_t ./docker-entrypoint.sh ./testsuite ./testresults
```

If you use the options `--testsuite /path/to/testsuite` or `--testresults /path/to/testresults`, then the pointed directories must also be relabeled with `svirt_sandbox_file_t`:

```bash
    chcon -Rt svirt_sandbox_file_t /path/to/testresults /path/to/testsuite
```
