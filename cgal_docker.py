from os import path
import logging
import docker
import re

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

def container_by_id(docker_client, Id):
    """Returns a container given an `Id`. Raises `TestsuiteError` if the
    `Id` cannot be found."""
    contlist = [cont for cont in docker_client.containers(all=True) if Id == cont[u'Id']]
    if len(contlist) != 1:
        raise TestsuiteError('Requested Container Id ' + Id + 'does not exist')
    return contlist[0]

def images(docker_client, images):
    """If `images` is `None`, returns a list of default images, else
    validates the list of images and returns it. Raises an exception
    if an invalid image is found.
    """
    if not images:
        return _default_images(docker_client)
    not_existing = _not_existing_images(docker_client, images)
    if len(not_existing) != 0:
        raise TestsuiteError('Could not find specified images: ' + ', '.join(not_existing))

    return images

def _default_images(docker_client):
    images = []
    for img in docker_client.images():
        tag = next((x for x in img[u'RepoTags'] if x.startswith(u'cgal-testsuite/')), None)
        if tag:
            images.append(tag)
    return images

def _not_existing_images(docker_client, images):
    """Checks if each image in the list `images` is actually a name
    for a docker image. Returns a list of not existing names."""
    # Since img might contain a :TAG we need to work it a little.
    return [img for img in images if len(docker_client.images(name=img.rsplit(':')[0])) == 0]

class ContainerRunner:
    # A regex to decompose the name of an image into the groups
    # ('user', 'name', 'tag')
    _image_name_regex = re.compile('(.*/)?([^:]*)(:.*)?')

    def __init__(self, docker_client, tester, tester_name, 
                 tester_address, force_rm, nb_jobs, testsuite, 
                 testresults, use_fedora_selinux_policy):
        assert path.isabs(testsuite.path), 'testsuite needs to be an absolute path'
        assert path.isabs(testresults), 'testresults needs to be an absolute path'
        self.docker_client = docker_client
        self.force_rm = force_rm
        self.environment={"CGAL_TESTER" : tester,
                          "CGAL_TESTER_NAME" : tester_name,
                          "CGAL_TESTER_ADDRESS": tester_address,
                          "CGAL_NUMBER_OF_JOBS" : nb_jobs
        }
        self.host_config = docker.utils.create_host_config(binds={
            testsuite.path:
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
            self.host_config['Binds'][0] += 'z'
            self.host_config['Binds'][1] += 'z'

    def run(self, image, cpuset):
        """Create and start a container of the `image` with `cpuset`."""

        container_id = self._create_container(image, cpuset)
        cont = container_by_id(self.docker_client, container_id)
        logging.info('Created container: {0} with id {1[Id]} from image {1[Image]} on cpus {2}'
                     .format(', '.join(cont[u'Names']), cont, cpuset))
        self.docker_client.start(container_id)
        return container_id

    def _create_container(self, img, cpuset):
        chosen_name = 'CGAL-{}-testsuite'.format(self._image_name_regex.search(img).group(2))
        existing = [cont for cont in self.docker_client.containers(all=True) if '/' + chosen_name in cont[u'Names']]
        assert len(existing) == 0 or len(existing) == 1, 'Length of existing containers is odd'

        if len(existing) != 0 and u'Exited' in existing[0][u'Status']:
            logging.info('An Exited container with name {} already exists. Removing.'.format(chosen_name))
            self.docker_client.remove_container(container=chosen_name)
        elif len(existing) != 0 and self.force_rm:
            logging.info('A non-Exited container with name {} already exists. Forcing exit and removal.'.format(chosen_name))
            self.docker_client.kill(container=chosen_name)
            self.docker_client.remove_container(container=chosen_name)
        elif len(existing) != 0:
            raise TestsuiteWarning('A non-Exited container with name {} already exists. Skipping.'.format(chosen_name))
        
        container = self.docker_client.create_container(
            image=img,
            name=chosen_name,
            entrypoint='/mnt/testsuite/docker-entrypoint.sh',
            volumes=['/mnt/testsuite', '/mnt/testresults'],
            cpuset=cpuset,
            environment=self.environment,
            host_config=self.host_config
        )

        if container[u'Warnings']:
            logging.warning('Container of image {} got created with warnings: {}'.format(img, container[u'Warnings']))

        return container[u'Id']

if __name__ == "__main__":
    pass
