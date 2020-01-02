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

import docker
import argparse
import os

def main():
    parser = argparse.ArgumentParser(
        description='This script launches build the cgal-testsuite images.'
        ' Unless any directories are specified this will process all immediate child directories'
        ' of the current working directory that contain a Dockerfile.')

    parser.add_argument('dirs', metavar='DIRNAME', nargs='*',
                        help='Directory to process.')
    parser.add_argument('--docker-url', metavar='protocol://hostname/to/docker.sock[:PORT]',
                        default='unix://var/run/docker.sock',
                        help='The protocol+hostname+port where the Docker server is hosted.')
    
    args = parser.parse_args()
    client = docker.Client(base_url=args.docker_url)

    if not args.dirs:
        fullnames = (os.path.join(os.getcwd(), name) for name in os.listdir(os.getcwd()))
        args.dirs = [name for name in fullnames if os.path.isfile(os.path.join(name, 'Dockerfile'))]

    print(args.dirs)

    for d in args.dirs:
        tag = 'cgal-testsuite/' + os.path.basename(d).lower()
        print('Building directory {} with tag {}'.format(d, tag))
        response = client.build(path=d, rm=True, tag=tag, stream=False)
        for l in response:
            print(l)
    
if __name__ == "__main__":
    main()
