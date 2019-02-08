# -*- coding: utf-8 -*-
'''
    pip3_state
    ~~~~~~~~~~

    Custom PIP state module which wraps the existing pip module to set/use some
    default settings/parameters. Python 3 specific.
'''

# Import python libs
from __future__ import absolute_import
import os
import types
import logging

# Import salt libs
import salt.states.pip_state
from salt.states.pip_state import *  # pylint: disable=wildcard-import,unused-wildcard-import
from salt.states.pip_state import installed as pip_state_installed
from salt.states.pip_state import _from_line  # pylint: disable=wildcard-import,unused-wildcard-import
from salt.states.pip_state import _pep440_version_cmp  # pylint: disable=wildcard-import,unused-wildcard-import
from salt.utils.functools import namespaced_function

__virtualname__ = 'pip3'

log = logging.getLogger(__name__)

# Let's namespace the pip_state_installed function
pip_state_installed = namespaced_function(pip_state_installed, globals())  # pylint: disable=invalid-name
uptodate = namespaced_function(salt.states.pip_state.uptodate, globals())  # pylint: disable=invalid-name
removed = namespaced_function(salt.states.pip_state.removed, globals())  # pylint: disable=invalid-name
_check_if_installed = namespaced_function(salt.states.pip_state._check_if_installed, globals())  # pylint: disable=invalid-name
_check_pkg_version_format = namespaced_function(salt.states.pip_state._check_pkg_version_format, globals())  # pylint: disable=invalid-name
_fulfills_version_spec = namespaced_function(salt.states.pip_state._fulfills_version_spec, globals())  # pylint: disable=invalid-name
_find_key = namespaced_function(salt.states.pip_state._find_key, globals())  # pylint: disable=invalid-name


def __virtual__():
    if 'pip.list' in __salt__:
        return __virtualname__
    return False


def installed(name, **kwargs):
    index_url = kwargs.pop('index_url', None)
    if index_url is None:
        index_url = 'https://artifactory.saltstack.net/artifactory/api/pypi/pypi-open/simple'
    extra_index_url = kwargs.pop('extra_index_url', None)
    if extra_index_url is None:
        extra_index_url = 'https://pypi.python.org/simple'

    bin_env = __salt__['pip.get_pip_bin'](
        kwargs.get('bin_env') or __salt__['config.get']('virtualenv_path', None),
        'pip3'
    )
    if isinstance(bin_env, list):
        bin_env = bin_env[0]
    log.warning('pip3 binary found: %s', bin_env)

    # Complementary set of cwd and target
    kwargs.setdefault('cwd', __salt__['config.get']('pip_cwd', None))
    kwargs.setdefault('target', __salt__['config.get']('pip_target', None))

    kwargs.update(
        index_url=index_url,
        extra_index_url=extra_index_url,
        bin_env=bin_env)
    return pip_state_installed(name, **kwargs)
