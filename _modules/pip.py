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

# Import salt libs
from salt.utils import namespaced_function
from salt.exceptions import CommandNotFoundError
import salt.modules.pip
from salt.modules.pip import *  # pylint: disable=wildcard-import,unused-wildcard-import
from salt.modules.pip import install as pip_install
from salt.modules.pip import list_ as pip_list

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


def get_pip_bin(bin_env):
    '''
    Locate the pip binary, either from `bin_env` as a virtualenv, as the
    executable itself, or from searching conventional filesystem locations
    '''
    pip_bin_name = 'pip3' if __pillar__.get('py3', False) else 'pip2'
    if not bin_env:
        which_result = __salt__['cmd.which_bin']([pip_bin_name])
        if which_result is None:
            raise CommandNotFoundError('Could not find a `pip` binary')
        if salt.utils.is_windows():
            return which_result
        return which_result

    # try to get pip bin from virtualenv, bin_env
    if os.path.isdir(bin_env):
        if salt.utils.is_windows():
            pip_bin = os.path.join(
                bin_env, 'Scripts', 'pip.exe')
        else:
            pip_bin = os.path.join(bin_env, 'bin', pip_bin_name)
        if os.path.isfile(pip_bin):
            return pip_bin
        msg = 'Could not find a `pip` binary in virtualenv {0}'.format(bin_env)
        raise CommandNotFoundError(msg)
    # bin_env is the pip binary
    elif os.access(bin_env, os.X_OK):
        if os.path.isfile(bin_env) or os.path.islink(bin_env):
            return bin_env
    else:
        raise CommandNotFoundError('Could not find a `pip` binary')


# An alias to the old private function
_get_pip_bin = get_pip_bin


def install(*args, **kwargs):  # pylint: disable=function-redefined
    pip_binary = _get_pip_bin(kwargs.get('bin_env'))
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
