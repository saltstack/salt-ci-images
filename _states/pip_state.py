# -*- coding: utf-8 -*-
'''
    pip_state
    ~~~~~~~~~

    Custom PIP state module which wraps the existing pip module to set/use some
    default settings/parameters
'''

# Import python libs
from __future__ import absolute_import
import os
import types

# Import salt libs
from salt.utils import namespaced_function
import salt.states.pip_state
from salt.states.pip_state import *  # pylint: disable=wildcard-import,unused-wildcard-import
from salt.states.pip_state import installed as pip_state_installed

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


__virtualname__ = 'pip'


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

    kwargs.update(
        index_url=index_url,
        extra_index_url=extra_index_url,
        user=sudo_user or None)
    return pip_state_installed(name, **kwargs)
