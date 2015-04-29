cgal-testsuite-dockerfiles
==========================

Dockerfiles and tools to run the CGAL testsuite inside containers.

Initially you need to build the images which you would like to use:

    cd CentOS-6
    docker build -t cgal-testsuite/centos6
    cd ..

To run the testsuite using this image:

    ./test_cgal.py --username **** --passwd **** --images cgal-testsuite/centos6

If you would like to use an already extraced internal release:

    ./test_cgal.py --use-local --testsuite /path/to/release --images cgal-testsuite/centos6
