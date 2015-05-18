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

import argparse
from getpass import getuser
from os import path
import re
import shutil
from socket import gethostname
import sys
import urllib2
import tarfile
import time
import tempfile
import docker
import paramiko
from multiprocessing import cpu_count
from xdg.BaseDirectory import load_first_config, xdg_config_home

class CustomArgumentParser(argparse.ArgumentParser):
    def __init__(self, *args, **kwargs):
        super(CustomArgumentParser, self).__init__(*args, **kwargs)

    def convert_arg_line_to_args(self, line):
        for arg in line.split():
            if not arg.strip():
                continue
            if arg[0] == '#':
                break
            yield arg

class TestsuiteException(Exception):
    pass

class TestsuiteWarning(TestsuiteException):
    """Warning exceptions thrown in this module."""
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return 'Testsuite Warning: ' + repr(self.value)

class TestsuiteError(TestsuiteException):
    """Error exceptions thrown in this module."""
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return 'Testsuite Error: ' + repr(self.value)

cgal_release_url='https://cgal.geometryfactory.com/CGAL/Members/Releases/'

def get_latest():
    print 'Trying to determine LATEST'
    try:
        response = urllib2.urlopen(cgal_release_url + 'LATEST')
        return response.read().strip()
    except urllib2.URLError as e:
        if hasattr(e, 'code') and e.code == 401:
            print 'Did you forget to provide --user and --passwd?'
        sys.exit('Failure retrieving LATEST: ' +  e.reason)

def get_cgal(latest, testsuite):
    download_from=cgal_release_url + latest
    download_to=path.join(testsuite, path.basename(download_from))
    print 'Trying to download latest release to ' + download_to

    if path.exists(download_to):
        print download_to + ' already exists, reusing'
        return download_to

    try:
        response = urllib2.urlopen(download_from)
        with open(download_to, "wb") as local_file:
            local_file.write(response.read())
        return download_to
    except urllib2.URLError as e:
        if hasattr(e, 'code') and e.code == 401:
            print 'Did you forget to provide --user and --passwd?'
        sys.exit('Failure retrieving the CGAL specified by latest.' + e.reason)

def extract(path):
    """Extract the CGAL release tar ball specified by `path` into the
    directory of `path`.  The tar ball can only contain a single
    directory, which cannot be an absolute path. Returns the path to
    the extracted directory."""
    print 'Extracting ' + path
    assert tarfile.is_tarfile(path), 'Path provided to extract is not a tarfile'
    tar = tarfile.open(path)
    commonprefix = path.commonprefix(tar.getnames())
    assert commonprefix != '.', 'Tarfile has no single common prefix'
    assert not path.isabs(commonprefix), 'Common prefix is an absolute path'
    tar.extractall(path.dirname(path)) # extract to the download path
    tar.close()
    return path.join(path.dirname(path), commonprefix)

def default_images():
    """Returns a list of all image tags starting with cgal-testsuite/."""
    images = []
    for img in client.images():
        tag = next((x for x in img[u'RepoTags'] if x.startswith(u'cgal-testsuite/')), None)
        if tag:
            images.append(tag)
    return images

def not_existing_images(images):
    """Checks if each image in the list `images` is actually a name
    for a docker image. Returns a list of not existing names."""
    # Since img might contain a :TAG we need to work it a little.
    return [img for img in images if len(client.images(name=img.rsplit(':')[0])) == 0]

def create_container(img, tester, tester_name, tester_address, force_rm, cpu_set, nb_jobs):
    # Since we cannot reliably inspect APIError, we need to check
    # first if a container with the name we would like to use already
    # exists. If so, we check it's status. If it is Exited, we kill
    # it. Otherwise we fall over.
    chosen_name = 'CGAL-' + image_name_regex.search(img).group(2) + '-testsuite'
    existing = [cont for cont in client.containers(all=True) if '/' + chosen_name in cont[u'Names']]
    assert len(existing) == 0 or len(existing) == 1, 'Length of existing containers is odd'

    if len(existing) != 0 and u'Exited' in existing[0][u'Status']:
        print 'An Exited container with name ' + chosen_name + ' already exists. Removing.'
        client.remove_container(container=chosen_name)
    elif len(existing) != 0 and force_rm:
        print 'A non-Exited container with name ' + chosen_name + ' already exists. Forcing exit and removal.'
        client.kill(container=chosen_name)
        client.remove_container(container=chosen_name)
    elif len(existing) != 0:
        raise TestsuiteWarning('A non-Exited container with name ' + chosen_name + ' already exists. Skipping.')

    container = client.create_container(
        image=img,
        name=chosen_name,
        entrypoint='/mnt/testsuite/docker-entrypoint.sh',
        volumes=['/mnt/testsuite', '/mnt/testresults'],
        cpuset=cpu_set,
        environment={"CGAL_TESTER" : tester,
                     "CGAL_TESTER_NAME" : tester_name,
                     "CGAL_TESTER_ADDRESS": tester_address,
                     "CGAL_NUMBER_OF_JOBS" : nb_jobs
        }
    )

    if container[u'Warnings']:
        print 'Container of image %s got created with warnings: %s' % (img, container[u'Warnings'])

    return container[u'Id']

def start_container(container, testsuite, testresults):
    client.start(container, binds={
        testsuite:
        {
            'bind': '/mnt/testsuite',
            'ro': True
        },
        testresults:
        {
            'bind': '/mnt/testresults',
            'ro': False
        }
    })
    return container

def run_container(img, tester, tester_name, tester_address, force_rm, cpu_set, nb_jobs, testsuite, testresults):
    container_id = create_container(img, tester, tester_name, tester_address, force_rm, cpu_set, nb_jobs)
    cont = container_by_id(container_id)
    print 'Created container:\t' + ', '.join(cont[u'Names']) + \
        '\n\twith id:\t' + cont[u'Id'] + \
        '\n\tfrom image:\t'  + cont[u'Image']
    start_container(container_id, testsuite, testresults)
    return container_id

def handle_results(cont_id, upload, testresult_dir):
    # Try to recover the name of the resulting tar.gz from the container logs.
    logs = client.logs(container=cont_id, tail=4)
    res = re.search(r'([^ ]*)\.tar\.gz', logs)
    if not res:
        raise TestsuiteError('Could not identify resulting tar.gz file from logs of ' + cont_id)
    tarf = path.join(testresult_dir, res.group(0))
    txtf = path.join(testresult_dir, res.group(1) + '.txt')

    if not path.isfile(tarf) or not path.isfile(txtf):
        raise TestsuiteError('Result Files ' + tarf + ' or ' + txtf + ' do not exist.')

    # Tar the tesresults results_${CGAL_TESTER}_${PLATFORM}.tar.gz results_${CGAL_TESTER}_${PLATFORM}.txt
    # into results_${CGAL_TESTER}_${PLATFORM}.tar.gz
    tmpd = tempfile.mkdtemp()
    shutil.move(tarf, tmpd)
    shutil.move(txtf, tmpd)
    # Double splitext, to handle tar.gz
    archive_name = path.join(testresult_dir, path.splitext(path.splitext(path.basename(tarf))[0])[0])
    archive_name = shutil.make_archive(archive_name, 'gztar', tmpd)
    print 'Created the archive ' + archive_name

    # Those are variables used by autotest_cgal:
    # COMPILER=`printf "%s" "$2" | tr -c '[A-Za-z0-9]./[=-=]*_\'\''\":?() ' 'x'`
    # FILENAME="${CGAL_RELEASE_ID}_${CGAL_TESTER}-test`datestr`-${COMPILER}-cmake.tar.gz"
    # LOGFILENAME="${CGAL_RELEASE_ID}-log`datestr`-${HOST}.gz"

    # uploaded as FILENAME

def upload_results(localpath, remotepath):
    ssh = paramiko.SSHClient()
    ssh.load_host_keys(path.expanduser(path.join("~", ".ssh", "known_hosts")))
    ssh.connect(server)
    sftp = ssh.open_sftp()
    sftp.put(localpath, remotepath)
    sftp.close()
    ssh.close()

# A regex to decompose the name of an image into the groups ('user', 'name', 'tag')
image_name_regex = re.compile('(.*/)?([^:]*)(:.*)?')

def container_by_id(Id):
    contlist = [cont for cont in client.containers(all=True) if Id == cont[u'Id']]
    if len(contlist) != 1:
        raise TestsuiteError('Requested Container Id ' + Id + 'does not exist')
    return contlist[0]

def calculate_cpu_sets(max_cpus, cpus_per_container):
    """Returns a list with strings specifying the CPU sets used for
    execution of this testsuite."""
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

def main():
    parser = CustomArgumentParser(
        description='''This script launches docker containers which run the CGAL testsuite.''',
        fromfile_prefix_chars='@')

    # Testing related arguments
    parser.add_argument('--images', nargs='*', help='List of images to launch, defaults to all prefixed with cgal-testsuite')
    parser.add_argument('--testsuite', metavar='/path/to/testsuite',
                        help='Absolute path where the release is going to be stored.',
                        default=path.abspath('./testsuite'))
    parser.add_argument('--testresults', metavar='/path/to/testresults',
                        help='Absolute path where the testresults are going to be stored.',
                        default=path.abspath('./testresults'))
    # TODO
    parser.add_argument('--packages', nargs='*',
                        help='List of packages to run the tests for, e.g. AABB_tree AABB_tree_Examples')

    # Docker related arguments
    parser.add_argument('--docker-url', metavar='protocol://hostname/to/docker.sock[:PORT]',
                        help='The protocol+hostname+port where the Docker server is hosted.', default='unix://var/run/docker.sock')
    parser.add_argument('--force-rm', action='store_true',
                        help='If a container with the same name already exists, force it to quit')
    parser.add_argument('--max-cpus', metavar='N', default=cpu_count(), type=int,
                        help='The maximum number of CPUs the testsuite is allowed to use at a single time. Defaults to all available cpus.')
    parser.add_argument('--container-cpus', metavar='N', default=1, type=int,
                        help='The number of CPUs a single container should have. Defaults to one.')
    parser.add_argument('--jobs', metavar='N', default=None, type=int,
                        help='The number of jobs a single container is going to launch. Defaults to --container-cpus.')

    # Download related arguments
    parser.add_argument('--use-local', action='store_true',
                        help='Use a local extracted CGAL release. --testsuite must be set to that release.')
    # TODO make internal releases and latest public?
    parser.add_argument('--user', help='Username for CGAL Members')
    parser.add_argument('--passwd', help='Password for CGAL Members')

    # Upload related arguments
    parser.add_argument('--upload-results', action='store_true', help='Actually upload the test results.')
    parser.add_argument('--tester', help='The tester', default=getuser())
    parser.add_argument('--tester-name', help='The name of the tester', default=gethostname())
    parser.add_argument('--tester-address', help='The mail address of the tester')

    if load_first_config('CGAL'):
        default_arg_file = path.join(load_first_config('CGAL'), 'test_cgal_rc')
    else:
        default_arg_file = path.join(xdg_config_home, 'test_cgal_rc')

    if path.isfile(default_arg_file):
        print 'Using default arguments from: ' + default_arg_file
        with open (default_arg_file, 'r') as f:
            for line in f.readlines():
                for arg in line.split():
                    sys.argv.append(arg)

    args = parser.parse_args()
    assert path.isabs(args.testsuite)
    assert path.isabs(args.testresults)

    if not args.jobs:
        args.jobs = args.container_cpus

    # Set-up a global docker client for convenience and easy
    # refactoring to a class.
    global client
    client = docker.Client(base_url=args.docker_url)

    if not args.images: # no images, use default
        args.images=default_images()

    not_existing = not_existing_images(args.images)
    if len(not_existing) != 0:
        raise TestsuiteError('Could not find specified images: ' + ', '.join(not_existing))

    if args.upload_results:
        assert args.tester, 'When uploading a --tester has to be given'
        assert args.tester_name, 'When uploading a --tester-name has to be given'
        assert args.tester_address, 'When uploading a --tester-name has to be given'
        assert 'gztar' in (item[0] for item in shutil.get_archive_formats()), 'When uploading results, gztar needs to be available'

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
        path_to_extracted_release=extract(path_to_release)
    else:
        print 'Using local CGAL release at ' + args.testsuite
        assert path.exists(args.testsuite), args.testsuite + ' is not a valid path'
        path_to_extracted_release=args.testsuite

    assert path.isdir(path_to_extracted_release), path_to_extracted_release + ' is not a directory'
    print 'Extracted release is at: ' + path_to_extracted_release

    # Copy the entrypoint to the testsuite volume
    shutil.copy('./docker-entrypoint.sh', path_to_extracted_release)

    # Explicit floor division from future
    cpu_sets = calculate_cpu_sets(args.max_cpus, args.container_cpus)
    nb_parallel_containers = len(cpu_sets)

    print 'Running a maximum of %i containers in parallel each using %i CPUs and using %i jobs' % (nb_parallel_containers, args.container_cpus, args.jobs)

    before_start = int(time.time())

    running_containers = []
    running_cpu_sets = []
    for img, cpu_set in zip(reversed(args.images), reversed(cpu_sets)):
        try:
            running_containers.append(
                run_container(img, args.tester, args.tester_name,
                              args.tester_address, args.force_rm,
                              cpu_set, args.jobs, path_to_extracted_release, args.testresults))
            running_cpu_sets.append(cpu_set)
            args.images.pop()
            cpu_sets.pop()
        except TestsuiteWarning as e:
            # BUG This leaves an unused cpuset for the rest of the run.
            # We are skipping this image.
            args.images.pop()
            cpu_sets.pop()
            print e
        except TestsuiteError as e:
            sys.exit(e.value)

    if len(running_containers) == 0:
        # Nothing to do. Go before we enter the blocking events call.
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
    for ev in client.events(since=before_start, decode=True):
        assert isinstance(ev, dict)

        try:
            index = running_containers.index(ev[u'id'])
        except ValueError:
            index = -1

        if index != -1: # we care
            container_info = container_by_id(ev[u'id'])
            if ev[u'status'] == u'die' and status_code_regex.search(container_info[u'Status']):
                res = status_code_regex.search(container_info[u'Status'])
                if not res:
                    print 'Could not parse exit status: '  + container_info[u'Status']
                    print 'Assuming dirty death of the container'
                elif res.group(1) != '0':
                    print 'Container exited with Error Code: ' + res.group(1)
                    print 'Assuming dirty death of the container'
                else:
                    print 'Container died cleanly, handling results'
                    try:
                        handle_results(ev[u'id'], args.upload_results, args.testresults)
                    except TestsuiteException as e:
                        print e
                # The freed up cpu_set.
                cpu_set = running_cpu_sets[index]
                del running_containers[index]
                del running_cpu_sets[index]
                if len(args.images) != 0:
                    running_containers.append(
                        run_container(args.images[-1], args.tester, args.tester_name,
                                      args.tester_address, args.force_rm,
                                      cpu_set, args.jobs, path_to_extracted_release, args.testresults))
                    running_cpu_sets.append(cpu_set)
                    args.images.pop()

        if len(running_containers) == 0:
            print 'All images handled. Exiting.'
            break

if __name__ == "__main__":
    main()
