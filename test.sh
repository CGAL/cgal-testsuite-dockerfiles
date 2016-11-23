#!/bin/bash 

if [ $1 ='ArchLinux' ]
then
  docker build -t cgal/testsuite-docker:fedora ./Fedora
elif [ $1 ='CentOS-5' ]
then
elif [ $1 ='CentOS-6' ]
then
elif [ $1 ='CentOS-7' ]
then
elif [ $1 ='Debian' ]
then
elif [ $1 ='Fedora' ]
then
elif [ $1 ='Ubuntu' ]
then
else
  return 1;
fi

