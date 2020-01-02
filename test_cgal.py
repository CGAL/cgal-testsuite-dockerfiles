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



import logging
from cgal_docker import *
from cgal_release import *
import atexit
import cgal_docker_args
import errno
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
    platform=platform_from_container(client, cont_id)
    result_basename = 'results_{}_{}'.format(tester, platform)
    tarf = path.join(testresult_dir, result_basename + '.tar.gz')
    txtf = path.join(testresult_dir, result_basename + '.txt')

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
        logging.info('Done uploading {}. Removing.'.format(local_path))
        os.remove(local_path)

def platform_from_container(client, cont_id):
    platform_regex = re.compile('^CGAL_TEST_PLATFORM=(.*)$')
    for e in client.inspect_container(container=cont_id)['Config']['Env']:
        res = platform_regex.search(e)
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

pidfile = '/tmp/test_cgal.pid'
def remove_pidfile():
    logging.info('Unlinking pidfile {}'.format(pidfile))
    os.unlink(pidfile)

def pid_exists(pid):
    """Check whether pid exists in the current process table.
    UNIX only.
    """
    if pid < 0:
        return False
    if pid == 0:
        # According to "man 2 kill" PID 0 refers to every process
        # in the process group of the calling process.
        # On certain systems 0 is a valid PID but we have no way
        # to know that in a portable fashion.
        raise ValueError('invalid PID 0')
    try:
        os.kill(pid, 0)
    except OSError as err:
        if err.errno == errno.ESRCH:
            # ESRCH == No such process
            return False
        elif err.errno == errno.EPERM:
            # EPERM clearly means there's a process to deny access to
            return True
        else:
            # According to "man 2 kill" possible error values are
            # (EINVAL, EPERM, ESRCH)
            raise
    else:
        return True

def main():
    logging.basicConfig(level=logging.INFO)
    parser = cgal_docker_args.parser()
    args = parser.parse_args()

    # Setup the pidfile handling
    if os.path.isfile(pidfile):
        logging.warning('pidfile {} already exists. Killing other process.'.format(pidfile))
        with open(pidfile, 'r') as pf:
            oldpid = int(pf.read().strip())
        try:
            os.kill(oldpid, signal.SIGTERM)
            # Wait for the process to terminate.
            while pid_exists(oldpid):
                pass
        except OSError:
            logging.warning('pidfile {} did contain invalid pid {}.'.format(pidfile, oldpid))

    with open(pidfile, 'w') as pf:
        pid = str(os.getpid())
        logging.info('Writing pidfile {} with pid {}'.format(pidfile, pid))
        pf.write(pid)

    # If no jobs are specified, use as many as we use cpus per
    # container.
    if not args.jobs:
        args.jobs = args.container_cpus

    client = docker.APIClient(base_url=args.docker_url, version='1.24', timeout=300)

    # Perform a check for existing, running containers.
    existing = [cont for cont in client.containers(filters = { 'status' : 'running'})]
    generic_name_regex = re.compile('CGAL-.+-testsuite')
    for cont in existing:
        for name in cont['Names']:
            if generic_name_regex.match(name):
                info.error('Testsuite Container {} of previous suite still running. Aborting. NOTE: This could also be a name clash.')
                sys.exit(0)


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
    subprocess.call(['cp', '--preserve=xattr', os.path.join(local_dir, 'docker-entrypoint.sh'), release.path])
    subprocess.call(['cp', '--preserve=xattr', os.path.join(local_dir, 'run-testsuite.sh'), release.path])

    cpu_sets = calculate_cpu_sets(args.max_cpus, args.container_cpus)
    nb_parallel_containers = len(cpu_sets)

    logging.info('Running a maximum of %i containers in parallel each using %i CPUs and using %i jobs' % (nb_parallel_containers, args.container_cpus, args.jobs))

    runner = ContainerRunner(client, args.tester, args.tester_name, 
                             args.tester_address, args.force_rm, args.jobs,
                             release, args.testresults, args.use_fedora_selinux_policy,
                             args.intel_license, args.mac_address)
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
    # work around it, we parse the ExitCode of the container die event and
    # base our decision on it.

    # Process events since starting our containers, so we don't miss
    # any event that might have occured while we were still starting
    # containers. The decode parameter has been documented as a
    # resolution to this issue
    # https://github.com/docker/docker-py/issues/585
    try:
        for ev in client.events(since=before_start, decode=True):
            assert isinstance(ev, dict)
            if ev['Type'] != 'container':
                continue;
            event_id = ev['id']

            if scheduler.is_ours(event_id): # we care
                if ev['status'] == 'die':
                    if ev['Actor']['Attributes']['exitCode']!='0':
                        logging.warning('Could not parse exit status: {}. Assuming dirty death of the container.'
                                        .format(ev['Actor']['Attributes']['exitCode']))
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

    if not args.use_local:
        logging.info('Cleaning up {}'.format(release.path))
        shutil.rmtree(release.path)

    remove_pidfile()

    if scheduler.errors_encountered:
      print((scheduler.error_buffer.getvalue()))
      exit(33)

if __name__ == "__main__":
    main()
