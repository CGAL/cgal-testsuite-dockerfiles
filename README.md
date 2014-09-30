CGAL-testsuite-dockerfiles
==========================

Docker files for the automated CGAL test suite

An example of use of the image `cgal.org:centos6-32`:

    docker run -v /home/lrineau/CGAL/branches/local-master.git:/local-master.git:ro --rm -i -t cgal.org:centos6-32 /bin/bash -c 'mkdir /build; cd build; QTDIR=/usr/lib/qt-3.3 CXXFLAGS="-I/usr/include/c++/4.4.4/i686-redhat-linux -m32" CFLAGS=-m32 cmake /local-master.git; make -j6; ls lib'

An example of use of the image `cgal.org:centos6`:

    docker run -v /home/lrineau/CGAL/branches/local-master.git:/local-master.git:ro --rm -i -t cgal.org:centos6 /bin/bash -c 'mkdir /build; cd build; QTDIR=/usr/lib64/qt-3.3 cmake /local-master.git; make -j6; ls lib'
