#!/usr/bin/env python3

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
    parser.add_argument('--cgal-dir', metavar='/path/to/cgal',
                        help='Path to a CGAL installation')
    parser.add_argument('--docker-url', metavar='protocol://hostname/to/docker.sock[:PORT]',
                        default='unix://var/run/docker.sock',
                        help='The protocol+hostname+port where the Docker server is hosted.')

    args = parser.parse_args()
    
    assert args.image
    assert args.cgal_dir
    args.cgal_dir = os.path.abspath(args.cgal_dir) # make the path absolute
    docker_client = docker.APIClient(base_url=args.docker_url)
    this_path = os.path.dirname(os.path.realpath(__file__))

    image_name_regex = re.compile('(.*/)?([^:]*)(:.*)?')
    res = image_name_regex.search(args.image)
    if 'testsuite-docker' in res.group(2):
        chosen_name = 'CGAL-{}-test_container'.format(res.group(3)[1:])
    elif res.group(3):
        chosen_name = 'CGAL-{}-{}-test_container'.format(res.group(2), res.group(3)[1:])
    else:
        chosen_name = 'CGAL-{}-test_container'.format(res.group(2))

    try:
        docker_client.remove_container(container=chosen_name, force=True)
    except docker.errors.NotFound:
        pass
    except docker.errors.APIError as e:
        logging.warning("Failed to remove container %s: %s", chosen_name, e)
    container = docker_client.create_container(
        image=args.image,
        name=chosen_name,
        environment={'CGAL_MODULES_DIR' : '/mnt/cgal/Installation/cmake/modules'},
        entrypoint=['/mnt/test/run-test.sh'],
        volumes=['/mnt/modules', '/mnt/test'],
        host_config=docker_client.create_host_config(binds={
            args.cgal_dir:
            {
                'bind': '/mnt/cgal',
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
        if ev['Type'] != 'container':
            continue;
        assert isinstance(ev, dict)
        if ev['id'] == container['Id'] and ev['status'] == 'die':
            # our container died, time to print the log
            break

    log = docker_client.logs(container=container).decode('utf-8')
    for line in log.splitlines():
        print(line)

    exit_code = docker_client.inspect_container(container['Id'])['State']['ExitCode']
    if exit_code != 0:
        logging.error('Container exited with code {}'.format(exit_code))
        exit(exit_code)
    else:
        logging.info('Container exited successfully')

if __name__ == "__main__":
    main()

