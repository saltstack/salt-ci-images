# -*- coding: utf-8 -*-
'''
    pip
    ~~~

    Custom PIP module which wraps the existing pip module to set/use some defaul
    settings/parameters
'''

# Import python libs
from __future__ import absolute_import
import os
import types
import logging
import pkg_resources

# Import salt libs
import salt.utils
from salt.utils import namespaced_function
from salt.exceptions import CommandNotFoundError
import salt.modules.pip
from salt.modules.pip import *  # pylint: disable=wildcard-import,unused-wildcard-import
from salt.modules.pip import install as pip_install
from salt.modules.pip import list_ as pip_list
try:
    from salt.utils.versions import LooseVersion
except ImportError:
    from distutils.version import LooseVersion

# Import 3rd Party libs
import salt.ext.six as six

# Let's namespace the pip_install function
pip_install = namespaced_function(pip_install, globals())  # pylint: disable=invalid-name
pip_list = namespaced_function(pip_list, globals())  # pylint: disable=invalid-name

# Let's namespace all other functions from the pip module
for name in dir(salt.modules.pip):
    attr = getattr(salt.modules.pip, name)
    if isinstance(attr, types.FunctionType):
        if attr == 'install':
            continue
        if attr in globals():
            continue
        globals()[name] = namespaced_function(attr, globals())


log = logging.getLogger(__name__)


__func_alias__ = {
    'list_': 'list'
}


def __virtual__():
    return True


def _list_or_not(ret):
    '''
    Return a list instead of a string when newer than 2017.7.5 and not 2018.3, or from a git checkout

    Caused by this PR #47196
    '''
    version = __grains__['saltversion']
    if (LooseVersion(version) >= LooseVersion('2017.7.6') and version != '2018.3.0') or 'n/a' in version:
        return [ret]
    return ret


def get_pip_bin(bin_env, pip_bin_name=None):
    '''
    Locate the pip binary, either from `bin_env` as a virtualenv, as the
    executable itself, or from searching conventional filesystem locations
    '''
    if pip_bin_name is None:
        # Always use pip3 if running with pillar="{py3: true}"
        # If running tests on CentOS 6, the Nitrogen and Develop branches run on Python2.7
        # so we need to set pip to 2.7 as well here (see PR #41039 in Salt repo)
        # otherwise, stick with the traditional pip2 binary.
        if __pillar__.get('py3', False):
            pip_bin_name = 'pip3'
        elif __grains__['os_family'] == 'RedHat' and int(__grains__['osmajorrelease']) == 6:
            pip_bin_name = 'pip2.7'
        else:
            pip_bin_name = 'pip2'

    if not bin_env:
        # not in / or c ignores the "root" directories as virtualenvs
        which_result = __salt__['cmd.which_bin']([pip_bin_name])
        if which_result is None:
            raise CommandNotFoundError('Could not find a `pip` binary')
        return _list_or_not(which_result)

    # try to get pip bin from virtualenv, bin_env
    if os.path.isdir(bin_env):
        if salt.utils.is_windows():
            pip_bin = os.path.join(bin_env, 'Scripts', 'pip.exe')
        else:
            pip_bin = os.path.join(bin_env, 'bin', pip_bin_name)
        if os.path.isfile(pip_bin):
            return _list_or_not(pip_bin)
        msg = 'Could not find a `pip` binary in virtualenv {0}'.format(bin_env)
        raise CommandNotFoundError(msg)
    # bin_env is the pip binary
    elif os.access(bin_env, os.X_OK):
        if os.path.isfile(bin_env) or os.path.islink(bin_env):
            return _list_or_not(bin_env)
    else:
        raise CommandNotFoundError('Could not find a `pip` binary')


# An alias to the old private function
_get_pip_bin = get_pip_bin


def install(*args, **kwargs):  # pylint: disable=function-redefined
    pip_binary = _get_pip_bin(kwargs.get('bin_env'))
    if isinstance(pip_binary, list):
        pip_binary = pip_binary[0]
    kwargs['bin_env'] = pip_binary
    env_vars = kwargs.pop('env_vars', None)
    if not env_vars:
        env_vars = {}
    # Some packages are not really competent at handling systems with poorly setup locales
    # Since this state tree properly configures the locale and yet, some packages, moto,
    # still fail under Python 3, let's explicitly set PYTHONIOENCODING environment variable
    # to utf-8
    if 'PYTHONIOENCODING' not in env_vars:
        log.debug('Explicitly setting environment variable "PYTHONIOENCODING=utf-8')
        env_vars['PYTHONIOENCODING'] = 'utf-8'
    if 'LC_ALL' not in env_vars:
        log.debug('Explicitly setting environment variable "LC_ALL=en_US.UTF-8"')
        env_vars['LC_ALL'] = 'en_US.UTF-8'
    kwargs['env_vars'] = env_vars
    return pip_install(*args, **kwargs)


def list_(*args, **kwargs):
    return pip_list(*args, **kwargs)
