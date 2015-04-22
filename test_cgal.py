#!/usr/bin/env python2
# Copyright (c) 2015 GeometryFactory (France). All rights reserved.
# All rights reserved.
#
# This file is part of CGAL (www.cgal.org).
# You can redistribute it and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Licensees holding a valid commercial license may use this file in
# accordance with the commercial license agreement provided with the software.
#
# This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
# WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
# Author(s)     : Philipp Moeller

import argparse
import getpass # getuser
import os
from os import path
import socket # gethostname
import sys
import urllib2
import tarfile
import docker

cgal_release_url='https://cgal.geometryfactory.com/CGAL/Members/Releases/'

def get_latest():
    print 'Trying to determine LATEST'
    try:
        response = urllib2.urlopen(cgal_release_url + 'LATEST')
        return response.read().strip()
    except urllib2.URLError as e:
        if hasattr(e, 'code') and e.code == 401:
            print 'Did you forget to provide --username and --passwd?'
        sys.exit('Failure retrieving LATEST: ' +  e.reason)

def get_cgal(latest, testsuite):
    download_from=cgal_release_url + latest
    download_to=os.path.join(testsuite, os.path.basename(download_from))
    print 'Trying to download latest release to ' + download_to

    if os.path.exists(download_to):
        print download_to + ' already exists, reusing'
        return download_to

    try:
        response = urllib2.urlopen(download_from)
        with open(download_to, "wb") as local_file:
            local_file.write(response.read())
        return download_to
    except urllib2.URLError as e:
        if hasattr(e, 'code') and e.code == 401:
            print 'Did you forget to provide --username and --passwd?'
        sys.exit('Failure retrieving the CGAL specified by latest.' + e.reason)

# TODO This could do with some verification of paths in the tarfile.
def extract(path):
    print 'Extracting ' + path
    tar = tarfile.open(path)
    tar.extractall(os.dirname(path)) # extract to the download path
    tar.close()
    os.remove(path)

def image_default():
    images = []
    client = docker.Client(base_url='unix://var/run/docker.sock')
    for img in client.images():
        # Find all images with a tag that has the prefix cgal-testsuite/
        tag = next((x for x in img[u'RepoTags'] if x.startswith(u'cgal-testsuite/')), None)
        if tag:
            images.append(tag)
    return images

# TODO pythonize me
def do_images_exist(images):
    client = docker.Client(base_url='unix://var/run/docker.sock')
    dimages = client.images()
    for img in images:
        found = False
        for dimg in dimages:
            if any(x == img for x in dimg[u'RepoTags']):
                found = True
                break
            else:
                found = False
        if not found:
            print 'Could not find image: ' + img
            return False
    return True

def create_container(img, client):
    return client.create_container(
        image=img,
        command='ls /mnt',
        volumes=['/mnt/testsuite', '/mnt/testresults']
    )

def start_container(container, client, testsuite, testresults):
    client.start(container, binds={
        testsuite:
        {
            'bind': '/mnt/testsuite',
            'ro': True
        },
        testresults:
        {
            'bind': '/mnt/testresults',
            'ro': True
        }
    })

def main():
    parser = argparse.ArgumentParser(
        description='''This script launches docker containers which run the CGAL testsuite.''')

    # Testing related arguments
    parser.add_argument('--images', nargs='*', help='List of images to launch, defaults to all prefixed with cgal-testsuite')
    parser.add_argument('--testsuite', metavar='/path/to/testsuite',
                        help='Absolute path where the release is going to be stored.',
                        default=os.path.abspath('./testsuite'))
    parser.add_argument('--testresults', metavar='/path/to/testresults',
                        help='Absolute path where the testresults are going to be stored.',
                        default=os.path.abspath('./testresults'))

    # Download related arguments
    parser.add_argument('--use-local', action='store_true', help='Actually upload the test results.')
    # TODO make internal releases and latest public?
    parser.add_argument('--user', help='Username for CGAL Members')
    parser.add_argument('--passwd', help='Password for CGAL Members')

    # Upload related arguments
    parser.add_argument('--upload-results', action='store_true', help='Actually upload the test results.')
    parser.add_argument('--tester', nargs=1, help='The tester', default=getpass.getuser())
    parser.add_argument('--tester-name', nargs=1, help='The name of the tester', default=socket.gethostname())
    parser.add_argument('--tester-address', nargs=1, help='The mail address of the tester')

    args = parser.parse_args()
    assert os.path.isabs(args.testsuite)
    assert os.path.isabs(args.testresults)

    if not args.images: # no images, use default
        args.images=image_default()
    assert(do_images_exist(args.images))

    print 'Using images ' + ', '.join(args.images)

    # Prepare urllib to use the magic words
    if not args.use_local and args.user and args.passwd:
        print 'Setting up user and password for download.'
        password_mgr = urllib2.HTTPPasswordMgrWithDefaultRealm()
        password_mgr.add_password(None, cgal_release_url, args.user, args.passwd)
        handler = urllib2.HTTPBasicAuthHandler(password_mgr)
        opener = urllib2.build_opener(handler)
        urllib2.install_opener(opener)

    if not args.use_local:
        latest = get_latest()
        print 'LATEST is ' + latest
        path_to_release=get_cgal(latest, args.testsuite)
        extract(path_to_release)
    else:
        print 'Using local CGAL'

    client = docker.Client(base_url='unix://var/run/docker.sock')
    container_ids = []
    for img in args.images:
        print 'Creating ' + img
        container_ids.append(create_container(img, client))

    print 'Created containers: ' + ', '.join(x[u'Id'] for x in container_ids)

    for cont in container_ids:
        start_container(cont, client, args.testsuite, args.testresults)

    # upload_results

if __name__ == "__main__":
    main()
