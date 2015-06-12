import logging
import argparse
import sys
import shlex
from os import path
from socket import gethostname
from getpass import getuser
from multiprocessing import cpu_count
from xdg.BaseDirectory import load_first_config, xdg_config_home

class CustomArgumentParser(argparse.ArgumentParser):
    def __init__(self, *args, **kwargs):
        super(CustomArgumentParser, self).__init__(*args, **kwargs)

    def convert_arg_line_to_args(self, line):
        return shlex.split(line, comments=True)

def parser():
    """Return the command line argument parser for test_cgal"""
    parser = CustomArgumentParser(
        description='''This script launches docker containers which run the CGAL testsuite.''',
        fromfile_prefix_chars='@')

    # Testing related arguments
    parser.add_argument('--images', nargs='*', 
                        help='List of images to launch, defaults to all prefixed with cgal-testsuite')
    parser.add_argument('--testsuite', metavar='/path/to/testsuite',
                        help='Absolute path where the release is going to be stored.',
                        default=path.abspath('./testsuite'))
    parser.add_argument('--testresults', metavar='/path/to/testresults',
                        help='Absolute path where the testresults are going to be stored.',
                        default=path.abspath('./testresults'))
    parser.add_argument('--packages', nargs='*',
                        help='List of package base names to run the tests for. Will always include Installation.'
                        'e.g. AABB_tree will run AABB_tree, AABB_tree_Examples, and AABB_tree_Demo.')

    # Docker related arguments
    parser.add_argument('--docker-url', metavar='protocol://hostname/to/docker.sock[:PORT]',
                        default='unix://var/run/docker.sock',
                        help='The protocol+hostname+port where the Docker server is hosted.')
    parser.add_argument('--force-rm', action='store_true',
                        help='If a container with the same name already exists, force it to quit')
    parser.add_argument('--max-cpus', metavar='N', default=cpu_count(), type=int,
                        help='The maximum number of CPUs the testsuite is allowed to use at a single time. Defaults to all available cpus.')
    parser.add_argument('--container-cpus', metavar='N', default=1, type=int,
                        help='The number of CPUs a single container should have. Defaults to one.')
    parser.add_argument('--jobs', metavar='N', default=None, type=int,
                        help='The number of jobs a single container is going to launch. Defaults to --container-cpus.')
    parser.add_argument('--use-fedora-selinux-policy', action='store_true', 
                        help='Mount volumes with z option to accomodate SELinux on Fedora.')

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
        logging.info('Using default arguments from: {}'.format(default_arg_file))
        sys.argv.insert(1, '@' + default_arg_file)

    return parser

if __name__ == "__main__":
    pass
