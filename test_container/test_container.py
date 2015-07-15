#!/usr/bin/env python2

import argparse
import docker
import time
import os
import logging
import re

def main():
    logging.basicConfig(level=logging.INFO)

    parser = argparse.ArgumentParser(
        description='''This script checks if a docker container can run the CGAL testsuite.''')

    parser.add_argument('--image', help='Image to check')
    parser.add_argument('--modules-dir', metavar='/path/to/cgal/Installation/cmake/modules',
                        help='Path to a CGAL cmake modules dir')
    parser.add_argument('--docker-url', metavar='protocol://hostname/to/docker.sock[:PORT]',
                        default='unix://var/run/docker.sock',
                        help='The protocol+hostname+port where the Docker server is hosted.')

    args = parser.parse_args()
    
    assert args.image
    assert args.modules_dir
    args.modules_dir = os.path.abspath(args.modules_dir) # make the path absolute
    docker_client = docker.Client(base_url=args.docker_url)
    this_path = os.path.dirname(os.path.realpath(__file__))

    image_name_regex = re.compile('(.*/)?([^:]*)(:.*)?')
    res = image_name_regex.search(args.image)
    if 'testsuite-docker' in res.group(2):
        chosen_name = 'CGAL-{}-test_container'.format(res.group(3)[1:])
    elif res.group(3):
        chosen_name = 'CGAL-{}-{}-test_container'.format(res.group(2), res.group(3)[1:])
    else:
        chosen_name = 'CGAL-{}-test_container'.format(res.group(2))

    container = docker_client.create_container(
        image=args.image,
        name=chosen_name,
        environment={'CGAL_MODULES_DIR' : '/mnt/modules'},
        entrypoint=['/mnt/test/run-test.sh'],
        volumes=['/mnt/modules', '/mnt/test'],
        host_config=docker.utils.create_host_config(binds={
            args.modules_dir:
            {
                'bind': '/mnt/modules',
                'ro': True
            },
            this_path:
            {
                'bind': '/mnt/test',
                'ro': True
            }
        })
    )

    logging.info('Created container {}'.format(container[u'Id']))

    if container[u'Warnings']:
        logging.warning('Container {} got created with warnings: {}'.format(container[u'Id'], container[u'Warnings']))
    before_start = int(time.time())
    docker_client.start(container)

    # We have to wait until the container dies to access the log since
    # docker_client.log(strem=True) is broken...
    for ev in docker_client.events(since=before_start, decode=True):
        assert isinstance(ev, dict)
        if ev[u'id'] == container[u'Id'] and ev[u'status'] == u'die':
            # our container died, time to print the log
            break

    log = docker_client.logs(container=container)
    print log

if __name__ == "__main__":
    main()

