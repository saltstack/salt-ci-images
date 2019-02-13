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
import pkg_resources

# Import salt libs
from salt.utils.functools import namespaced_function
import salt.states.pip_state
from salt.states.pip_state import *  # pylint: disable=wildcard-import,unused-wildcard-import
from salt.states.pip_state import installed as pip_state_installed

try:
    import pip
    HAS_PIP = True
except ImportError:
    HAS_PIP = False

if HAS_PIP is True:
    try:
        from pip.req import InstallRequirement
        _from_line = InstallRequirement.from_line
    except ImportError:
        # pip 10.0.0 move req module under pip._internal
        try:
            try:
                from pip._internal.req import InstallRequirement
                _from_line = InstallRequirement.from_line
            except AttributeError:
                from pip._internal.req.constructors import install_req_from_line as _from_line
        except ImportError:
            HAS_PIP = False

    try:
        from pip.exceptions import InstallationError
    except ImportError:
        InstallationError = ValueError

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

salt.states.pip_state.HAS_PIP = HAS_PIP
try:
    salt.states.pip_state._from_line = _from_line
except NameError:
    pass


__virtualname__ = 'pip2'


def __virtual__():
    if 'pip.list' in __salt__:
        return __virtualname__
    return False


def installed(name, **kwargs):
    index_url = kwargs.pop('index_url', None)
    if index_url is None:
        index_url = 'https://oss-nexus.aws.saltstack.net/repository/salt-proxy/simple'
    extra_index_url = kwargs.pop('extra_index_url', None)
    if extra_index_url is None:
        extra_index_url = 'https://pypi.python.org/simple'

    if __grains__['os_family'] == 'RedHat' and int(__grains__['osmajorrelease']) == 6:
        pip_bin_name = 'pip2.7'
    else:
        pip_bin_name = 'pip2'
    bin_env = __salt__['pip.get_pip_bin'](kwargs.get('bin_env'), pip_bin_name)
    if isinstance(bin_env, list):
        bin_env = bin_env[0]
    log.warning('pip2 binary found: %s', bin_env)

    kwargs.update(
        index_url=index_url,
        extra_index_url=extra_index_url,
        bin_env=bin_env)
    return pip_state_installed(name, **kwargs)
