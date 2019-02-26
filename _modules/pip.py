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
import re
import types
import logging
import pkg_resources

# Import salt libs
import salt.utils
try:
    from salt.utils.functools import namespaced_function
except (ImportError, AttributeError):
    from salt.utils import namespaced_function
try:
    from salt.utils.platform import is_windows
except (ImportError, AttributeError):
    from salt.utils import is_windows
from salt.utils.versions import LooseVersion
from salt.exceptions import CommandNotFoundError
import salt.modules.pip
from salt.modules.pip import *  # pylint: disable=wildcard-import,unused-wildcard-import
from salt.modules.pip import install as pip_install
from salt.modules.pip import freeze as pip_freeze
from salt.modules.pip import list_ as pip_list
from salt.modules.pip import _get_pip_bin as __get_pip_bin

# Import 3rd Party libs
import salt.ext.six as six

# Let's namespace the pip_install function
pip_install = namespaced_function(pip_install, globals())  # pylint: disable=invalid-name
pip_freeze = namespaced_function(pip_freeze, globals())  # pylint: disable=invalid-name
pip_list = namespaced_function(pip_list, globals())  # pylint: disable=invalid-name
__get_pip_bin = namespaced_function(__get_pip_bin, globals())

# Let's namespace all other functions from the pip module
for name in dir(salt.modules.pip):
    attr = getattr(salt.modules.pip, name)
    if isinstance(attr, types.FunctionType):
        if attr in ('install', 'freeze', 'list', 'list_', __get_pip_bin):
            continue
        #if attr in globals():
        #    continue
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
    _version = __grains__['saltversion']
    if (LooseVersion(_version) >= LooseVersion('2017.7.6') and _version != '2018.3.0') or 'n/a' in _version:
        return [ret]
    return ret


def get_pip_bin(bin_env, pip_bin_name=None, raise_error=True):
    '''
    Locate the pip binary, either from `bin_env` as a virtualenv, as the
    executable itself, or from searching conventional filesystem locations
    '''
    log.debug('Calling get_pip_bin on custom pip moule. bin_env: %s, pip_bin_name: %s', bin_env, pip_bin_name)
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
        log.debug('pip_bin_name resolved to: %s', pip_bin_name)


    if not bin_env:
        # not in / or c ignores the "root" directories as virtualenvs
        which_result = __salt__['cmd.which_bin']([pip_bin_name])
        if which_result is None:
            return _list_or_not(__get_pip_bin(bin_env))
            #raise CommandNotFoundError('Could not find a `pip` binary')
        log.debug('bin_env was None, lookup for pip_bin_name(%s) is: %s', pip_bin_name, which_result)
        return _list_or_not(which_result)

    # try to get pip bin from virtualenv, bin_env
    if os.path.isdir(bin_env):
        log.debug('bin_env is a directory')
        if is_windows():
            pip_bin = os.path.join(bin_env, 'Scripts', 'pip.exe')
        else:
            pip_bin = os.path.join(bin_env, 'bin', pip_bin_name)
        log.debug('resolved pip_bin: %s', pip_bin)
        if os.path.isfile(pip_bin):
            log.debug('Returning pip_bin executable: %s', pip_bin)
            cache_pip_version(pip_bin)
            return _list_or_not(pip_bin)
        msg = 'Could not find a `pip` binary in virtualenv {0}'.format(bin_env)
        raise CommandNotFoundError(msg)
    # bin_env is the pip binary
    elif os.access(bin_env, os.X_OK):
        log.debug('bin_env(%s) is not a direactory', bin_env)
        if os.path.isfile(bin_env) or os.path.islink(bin_env):
            log.debug('bin_env(%s) exists, returning it', bin_env)
            cache_pip_version(bin_env)
            return _list_or_not(bin_env)
    else:
        log.debug('Could not find a pip binary with bin_env(%s) and pip_bin_name(%s)!!!!', bin_env, pip_bin_name)
        return _list_or_not(__get_pip_bin(bin_env))
        #if raise_error:
        #    raise CommandNotFoundError('Could not find a `pip` binary')


# An alias to the old private function
_get_pip_bin = get_pip_bin


def install(*args, **kwargs):  # pylint: disable=function-redefined
    log.debug('custom pip module // pip.install called')
    pip_binary = get_pip_bin(kwargs.get('bin_env'))
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
    if kwargs.get('cwd') is None:
        if is_windows():
            # On windows, the cwd must the same directory as the pip executable
            kwargs['cwd'] = os.path.dirname(pip_binary)
        else:
            kwargs['cwd'] = '/'
    cache_pip_version(pip_binary, kwargs.get('cwd'))
    return pip_install(*args, **kwargs)


def list_(prefix=None,
          bin_env=None,
          user=None,
          cwd=None,
          env_vars=None,
          **kwargs):
    log.debug('custom pip module // pip.list called // kwargs: %s', kwargs)
    pip_binary = get_pip_bin(bin_env)
    if isinstance(pip_binary, list):
        pip_binary = pip_binary[0]
    bin_env = pip_binary
    if cwd is None:
        if is_windows():
            # On windows, the cwd must the same directory as the pip executable
            cwd = os.path.dirname(pip_binary)
        else:
            cwd = '/'
    cache_pip_version(pip_binary, cwd)
    return pip_list(prefix=prefix,
                    bin_env=bin_env,
                    user=user,
                    cwd=cwd,
                    env_vars=env_vars,
                    **kwargs)


def freeze(bin_env=None,
           user=None,
           cwd=None,
           use_vt=False,
           env_vars=None,
           **kwargs):
    log.debug('custom pip module // pip.freeze called')
    pip_binary = get_pip_bin(bin_env)
    if isinstance(pip_binary, list):
        pip_binary = pip_binary[0]
    bin_env = pip_binary
    if cwd is None:
        if is_windows():
            # On windows, the cwd must the same directory as the pip executable
            cwd = os.path.dirname(pip_binary)
        else:
            cwd = '/'
    cache_pip_version(pip_binary, cwd)
    return pip_freeze(bin_env=bin_env,
                      user=user,
                      cwd=cwd,
                      use_vt=use_vt,
                      env_vars=env_vars,
                      **kwargs)


def cache_pip_version(pip_binary, cwd=None):
    log.debug('custom pip module // pip.cache_pip_version called')
    contextkey = 'pip.version'
    if pip_binary is not None:
        contextkey = '{}.{}'.format(contextkey, pip_binary)

    if contextkey in __context__:
        return __context__[contextkey]

    if isinstance(pip_binary, list):
        cmd = pip_binary
    else:
        cmd = [pip_binary]
    cmd.append('--version')
    if cwd is None:
        if is_windows():
            cwd = os.path.dirname(pip_binary)
        else:
            cwd = '/'

    ret = __salt__['cmd.run_all'](cmd, cwd=cwd, python_shell=False)
    if ret['retcode']:
        raise CommandNotFoundError('Could not find a `pip` binary')

    try:
        pip_version = re.match(r'^pip (\S+)', ret['stdout']).group(1)
    except AttributeError:
        pip_version = None

    __context__[contextkey] = pip_version
    return pip_version
