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

from cgal_docker import *
import cgal_docker_args
from os import path
import re
import shutil
import sys
import urllib2
import tarfile
import time
import tempfile
import docker
import subprocess

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

def extract(path_to_release_tar):
    """Extract the CGAL release tar ball specified by `path_to_release_tar` into the
    directory of `path_to_release_tar`.  The tar ball can only contain a single
    directory, which cannot be an absolute path. Returns the path to
    the extracted directory."""
    print 'Extracting ' + path_to_release_tar
    assert tarfile.is_tarfile(path_to_release_tar), 'Path provided to extract is not a tarfile'
    tar = tarfile.open(path_to_release_tar)
    commonprefix = path.commonprefix(tar.getnames())
    assert commonprefix != '.', 'Tarfile has no single common prefix'
    assert not path.isabs(commonprefix), 'Common prefix is an absolute path'
    tar.extractall(path.dirname(path_to_release_tar)) # extract to the download path
    tar.close()
    return path.join(path.dirname(path_to_release_tar), commonprefix)

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

def create_container(img, tester, tester_name, tester_address, force_rm, cpu_set, nb_jobs, testsuite, testresults):
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

    config = docker.utils.create_host_config(binds={
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

    if use_fedora_selinux_policy:
        config['Binds'][0] += 'z'
        config['Binds'][1] += 'z'

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
        },
        host_config=config
    )

    if container[u'Warnings']:
        print 'Container of image %s got created with warnings: %s' % (img, container[u'Warnings'])

    return container[u'Id']

def run_container(img, tester, tester_name, tester_address, force_rm, cpu_set, nb_jobs, testsuite, testresults):
    container_id = create_container(img, tester, tester_name, tester_address, force_rm, cpu_set, nb_jobs, testsuite, testresults)
    cont = container_by_id(container_id)
    print 'Created container:\t' + ', '.join(cont[u'Names']) + \
        '\n\twith id:\t' + cont[u'Id'] + \
        '\n\tfrom image:\t'  + cont[u'Image']
    client.start(container_id)
    return container_id

def handle_results(cont_id, upload, testresult_dir, testsuite_dir, tester):
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

    # Build the filename according to:
    # CGAL-4.7-Ic-29_lrineau-test-ArchLinux.tar.gz
    release_id='NO_VERSION_FILE'
    try:
        version_file = path.join(testsuite_dir, 'VERSION')
        fp = open(version_file)
    except IOError:
        print 'Error opening VERSION file'
    else:
        with fp:
            release_id=fp.read().replace('\n', '')

    platform=platform_from_container(cont_id)

    archive_name = path.join(testresult_dir, 'CGAL-{0}_{1}-test-{2}'.format(release_id, tester, platform))
    archive_name = shutil.make_archive(archive_name, 'gztar', tmpd)
    print 'Created the archive ' + archive_name
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
    try:
        print 'Uploading ' + local_path
        subprocess.check_call(['scp',
                               local_path,
                               'cgaltest@cgaltest.geometryfactory.com:incoming/{}'.format(path.basename(local_path)) ])
    except subprocess.CalledProcessError as e:
        print 'Could not upload result file. SCP failed with error code {}'.format(e.returncode)
    print 'Done uploading ' + local_path

# A regex to decompose the name of an image into the groups ('user', 'name', 'tag')
image_name_regex = re.compile('(.*/)?([^:]*)(:.*)?')

def platform_from_container(cont_id):
    # We assume that the container is already dead and that this will not loop
    # forever.
    platform_regex = re.compile('^CGAL_TEST_PLATFORM=(.*)$')
    for line in client.logs(container=cont_id, stream=True):
        res = platform_regex.search(line)
        if res:
            return res.group(1)
    return 'NO_TEST_PLATFORM'

def container_by_id(Id):
    contlist = [cont for cont in client.containers(all=True) if Id == cont[u'Id']]
    if len(contlist) != 1:
        raise TestsuiteError('Requested Container Id ' + Id + 'does not exist')
    return contlist[0]

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

def main():
    parser = cgal_docker_args.parser()
    args = parser.parse_args()

    args = parser.parse_args()
    assert path.isabs(args.testsuite)
    assert path.isabs(args.testresults)

    if not args.jobs:
        args.jobs = args.container_cpus

    global use_fedora_selinux_policy
    use_fedora_selinux_policy = args.use_fedora_selinux_policy

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
        assert args.tester_address, 'When uploading a --tester-address has to be given'
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
                        handle_results(ev[u'id'], args.upload_results, args.testresults,
                                       path_to_extracted_release, args.tester)
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
