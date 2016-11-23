#!/bin/bash 

if [ "$1" == --Fedora ]
then
  docker build -t cgal/testsuite-docker:fedora ./Fedora
else
  return 1;
fi
