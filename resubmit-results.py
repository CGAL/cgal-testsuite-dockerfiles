#!/usr/bin/env python2

import docker
import re
from test_cgal import platform_from_container,handle_results
import cgal_docker_args
import cgal_release
from cgal_docker import TestsuiteError

parser = cgal_docker_args.parser()
args = parser.parse_args()

client=docker.APIClient(base_url=args.docker_url)

if not args.images:
    args.images = []
    for i in client.images(name='docker.io/cgal/testsuite-docker'):
        args.images.append(i['RepoTags'][0])

print(('Using images {}'.format(', '.join(args.images))))
release = cgal_release.Release(args.testsuite, args.use_local, args.user, args.passwd)
print(('Using release ' + release.version))

for c in client.containers(filters={ 'status': 'exited' }):
    if not c['Image'] in args.images:
        continue
    id = c['Id']
    platform = platform_from_container(client, id)
    print(('Resubmit results for platform ' + platform))
    try:
        handle_results(client, id, args.upload_results, args.testresults,
                       release, args.tester)
    except TestsuiteError as e:
        print(('  ERROR: ' + str(e)))
