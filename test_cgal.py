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

from __future__ import division

import logging
from cgal_docker import *
from cgal_release import *
import cgal_docker_args
import os
import re
import shutil
import sys
import time
import tempfile
import docker
import signal
import subprocess

def handle_results(client, cont_id, upload, testresult_dir, release, tester):
    # Try to recover the name of the resulting tar.gz from the container logs.
    logs = client.logs(container=cont_id, tail=4)
    res = re.search(r'([^ ]*)\.tar\.gz', logs)
    if not res:
        raise TestsuiteError('Could not identify resulting tar.gz file from logs of {}'.format(cont_id))
    tarf = path.join(testresult_dir, res.group(0))
    txtf = path.join(testresult_dir, res.group(1) + '.txt')

    if not path.isfile(tarf) or not path.isfile(txtf):
        raise TestsuiteError('Result Files {} or {} do not exist.'.format(tarf, txtf))

    # Tar the tesresults results_${CGAL_TESTER}_${PLATFORM}.tar.gz results_${CGAL_TESTER}_${PLATFORM}.txt
    # into results_${CGAL_TESTER}_${PLATFORM}.tar.gz
    tmpd = tempfile.mkdtemp()
    shutil.move(tarf, tmpd)
    shutil.move(txtf, tmpd)

    # Build the filename according to:
    # CGAL-4.7-Ic-29_lrineau-test-ArchLinux.tar.gz
    if release.version:
        release_id = release.version
    else:
        release_id = 'NO_VERSION_FILE'

    platform=platform_from_container(client, cont_id)

    archive_name = path.join(testresult_dir, 'CGAL-{0}_{1}-test-{2}'.format(release_id, tester, platform))
    archive_name = shutil.make_archive(archive_name, 'gztar', tmpd)
    logging.info('Created the archive {}'.format(archive_name))
    if upload:
        # TODO exceptions
        upload_results(archive_name)


# This code could use paramiko as well. This would have the benefit of
# not relying on the user configuration of ssh/scp and we could
# provide clearer error messages. Paramiko although has some
# drawbacks: it does not support the same set of keys and so it will
# not find cgaltest.geometryfactory.com in the known_hosts file if it
# has been added there with OpenSSH. A workaround would be to add the
# host manually (very surprising to new users) or to auto-accept new
# hosts (security issue).
def upload_results(local_path):
    """Upload the file at `local_path` to the incoming directory of the
    cgal test server."""
    logging.info('Uploading {}'.format(local_path))
    try:
        subprocess.check_call(['scp',
                               local_path,
                               'cgaltest@cgaltest.geometryfactory.com:incoming/{}'.format(path.basename(local_path)) ])
    except subprocess.CalledProcessError as e:
        logging.error('Could not upload result file. SCP failed with error code {}'.format(e.returncode))
    else:
        logging.info('Done uploading {}'.format(local_path))

def platform_from_container(client, cont_id):
    # We assume that the container is already dead and that this will not loop
    # forever.
    platform_regex = re.compile('^CGAL_TEST_PLATFORM=(.*)$')
    for line in client.logs(container=cont_id, stream=True):
        res = platform_regex.search(line)
        if res:
            return res.group(1)
    return 'NO_TEST_PLATFORM'

def calculate_cpu_sets(max_cpus, cpus_per_container):
    """Returns a list with strings specifying the CPU sets used for
    execution of this testsuite."""
    # Explicit floor division from future
    nb_parallel_containers = max_cpus // cpus_per_container
    cpu = 0
    cpu_sets = []
    for r in range(0, nb_parallel_containers):
        if cpus_per_container == 1:
            cpu_sets.append(repr(cpu))
        else:
            cpu_sets.append('%i-%i' % (cpu,  cpu + cpus_per_container - 1))
        cpu += cpus_per_container
    return cpu_sets

def term_handler(self, *args):
    sys.exit(0)

def main():
    logging.basicConfig(level=logging.INFO)
    parser = cgal_docker_args.parser()
    args = parser.parse_args()

    # If no jobs are specified, use as many as we use cpus per
    # container.
    if not args.jobs:
        args.jobs = args.container_cpus

    client = docker.Client(base_url=args.docker_url)
    args.images = images(client, args.images)

    if args.upload_results:
        assert args.tester, 'When uploading a --tester has to be given'
        assert args.tester_name, 'When uploading a --tester-name has to be given'
        assert args.tester_address, 'When uploading a --tester-address has to be given'
        assert 'gztar' in (item[0] for item in shutil.get_archive_formats()), 'When uploading results, gztar needs to be available'

    logging.info('Using images {}'.format(', '.join(args.images)))

    release = Release(args.testsuite, args.use_local, args.user, args.passwd)
    if args.packages:
        release.scrub(args.packages)

    logging.info('Extracted release {} is at {}'.format(release.version, release.path))

    local_dir = os.path.dirname(os.path.realpath(__file__))
    # Copy the entrypoint to the testsuite volume
    shutil.copy(os.path.join(local_dir, 'docker-entrypoint.sh'), release.path)
    shutil.copy(os.path.join(local_dir, 'run-testsuite.sh'), release.path)

    cpu_sets = calculate_cpu_sets(args.max_cpus, args.container_cpus)
    nb_parallel_containers = len(cpu_sets)

    logging.info('Running a maximum of %i containers in parallel each using %i CPUs and using %i jobs' % (nb_parallel_containers, args.container_cpus, args.jobs))


    if args.intel_license and os.path.isdir(args.intel_license):
        intel_license = args.intel_license
        logging.info('Using {} as intel license directory'.format(intel_license))
    else:
        intel_license = None
        logging.info('Not using an intel license directory')

    runner = ContainerRunner(client, args.tester, args.tester_name, 
                             args.tester_address, args.force_rm, args.jobs,
                             release, args.testresults, args.use_fedora_selinux_policy,
                             intel_license)
    scheduler = ContainerScheduler(runner, args.images, cpu_sets)

    # Translate SIGTERM to SystemExit exception
    signal.signal(signal.SIGTERM, term_handler)

    before_start = int(time.time())
    launch_result = scheduler.launch()
    if not launch_result:
        logging.error('Exiting without starting any containers.')
        sys.exit('Exiting without starting any containers.')

    # Possible events are: create, destroy, die, export, kill, pause,
    # restart, start, stop, unpause.

    # We only care for die events. The problem is that a killing or
    # stopping a container will also result in a die event before
    # emitting a kill/stop event. So, when a container dies, we cannot
    # know if it got stopped, killed or exited regularly. Waiting for
    # the next event with a timeout is very flaky and error
    # prone. This is a known design flaw of the docker event API. To
    # work around it, we parse the Exit Status of the container and
    # base our decision on the error code.
    status_code_regex = re.compile(r'Exited \((.*)\)')

    # Process events since starting our containers, so we don't miss
    # any event that might have occured while we were still starting
    # containers. The decode parameter has been documented as a
    # resolution to this issue
    # https://github.com/docker/docker-py/issues/585
    try:
        for ev in client.events(since=before_start, decode=True):
            assert isinstance(ev, dict)
            event_id = ev[u'id']

            if scheduler.is_ours(event_id): # we care
                container_info = container_by_id(client, event_id)
                if ev[u'status'] == u'die' and status_code_regex.search(container_info[u'Status']):
                    res = status_code_regex.search(container_info[u'Status'])
                    if not res:
                        logging.warning('Could not parse exit status: {}. Assuming dirty death of the container.'
                                        .format(container_info[u'Status']))
                    elif res.group(1) != '0':
                        logging.warning('Container exited with Error Code: {}. Assuming dirty death of the container.'
                                        .format(res.group(1)))
                    else:
                        logging.info('Container died cleanly, handling results.')
                        try:
                            handle_results(client, event_id, args.upload_results, args.testresults,
                                           release, args.tester)
                        except TestsuiteException as e:
                            logging.exception(str(e))
                            # The freed up cpu_set.
                    scheduler.container_finished(event_id)
                    if not scheduler.launch():
                        logging.info('No more images to launch.')
                    if not scheduler.containers_running():
                        logging.info('Handled all images.')
                        break
    except KeyboardInterrupt:
        logging.warning('SIGINT received, cleaning up containers!')
        scheduler.kill_all()
    except SystemExit:
        logging.warning('SIGTERM received, cleaning up containers!')
        scheduler.kill_all()

if __name__ == "__main__":
    main()
