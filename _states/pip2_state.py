# -*- coding: utf-8 -*-
'''
    pip2_state
    ~~~~~~~~~~

    Custom PIP state module which wraps the existing pip module to set/use some
    default settings/parameters. Python 2 specific.
'''

# Import python libs
from __future__ import absolute_import
import os
import types
import logging

# Import salt libs
from salt.utils import namespaced_function
from salt.exceptions import CommandNotFoundError
import salt.states.pip_state
from salt.states.pip_state import *  # pylint: disable=wildcard-import,unused-wildcard-import
from salt.states.pip_state import installed as pip_state_installed

# Import 3rd Party libs
import salt.ext.six as six

log = logging.getLogger(__name__)

# Let's namespace the pip_state_installed function
pip_state_installed = namespaced_function(pip_state_installed, globals())  # pylint: disable=invalid-name

# Let's namespace all other functions from the pip_state module
for name in dir(salt.states.pip_state):
    attr = getattr(salt.states.pip_state, name)
    if isinstance(attr, types.FunctionType):
        if attr in ('installed',):
            continue
        if attr in globals():
            continue
        globals()[name] = namespaced_function(attr, globals())


def _get_pip_bin(bin_env):
    '''
    Locate the pip binary, either from `bin_env` as a virtualenv, as the
    executable itself, or from searching conventional filesystem locations
    '''
    pip_bin_name = 'pip2'
    if not bin_env:
        which_result = __salt__['cmd.which'](pip_bin_name)
        if salt.utils.is_windows() and six.PY2:
            which_result.encode('string-escape')
        if which_result is None:
            raise CommandNotFoundError('Could not find a `pip` binary')
        return which_result

    # try to get pip bin from virtualenv, bin_env
    if os.path.isdir(bin_env):
        if salt.utils.is_windows():
            if six.PY2:
                pip_bin = os.path.join(
                    bin_env, 'Scripts', 'pip.exe').encode('string-escape')
            else:
                pip_bin = os.path.join(bin_env, 'Scripts', 'pip.exe')
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

__virtualname__ = 'pip2'


def __virtual__():
    if 'pip.list' in __salt__:
        return __virtualname__
    return False


def installed(name, **kwargs):
    index_url = kwargs.pop('index_url', None)
    if index_url is None:
        index_url = 'https://pypi.c7.saltstack.net/simple'
    extra_index_url = kwargs.pop('extra_index_url', None)
    if extra_index_url is None:
        extra_index_url = 'https://pypi.python.org/simple'

    sudo_user = os.environ.get('SUDO_USER')
    bin_env = _get_pip_bin(kwargs.get('bin_env'))
    log.warning('pip2 binary found: %s', bin_env)

    kwargs.update(
        index_url=index_url,
        extra_index_url=extra_index_url,
        bin_env=bin_env,
        user=sudo_user or None)
    return pip_state_installed(name, **kwargs)
