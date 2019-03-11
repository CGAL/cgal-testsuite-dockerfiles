#!/bin/bash

#setup ssh
# workaround for permission problems with ssh
mkdir -p ~/.ssh
cp /tmp_ssh/* ~/.ssh

cd /cgal_root/
source "env.sh"
#launch script
bash $CGAL_DIR/developer_scripts/run_testsuite_with_cmake
#clean-up
cd /cgal_root/
rm -rf $CGAL_DIR/cmake/platforms/*
rm env.sh