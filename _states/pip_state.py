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
    kwargs = salt.utils.clean_kwargs(**kwargs)
    return pip_state_installed(name, **kwargs)

def mod_aggregate(low, chunks, running):
    '''
    The mod_aggregate function which looks up all packages in the available
    low chunks and merges them into a single pkgs ref in the present low data
    '''
    pkgs = []
    # What functions should we aggregate?
    agg_enabled = ['installed',]
    # The `low` data is just a dict with the state, function (fun) and
    # arguments passed in from the sls
    if low.get('fun') not in agg_enabled:
        return low
    # Now look into what other things are set to execute
    for chunk in chunks:
        # The state runtime uses "tags" to track completed jobs, it may
        # look familiar with the _|-
        tag = salt.utils.gen_state_tag(chunk)
        if tag in running:
            # Already ran the pkg state, skip aggregation
            continue
        if chunk.get('state') == 'pip':
            if '__agg__' in chunk:
                continue
            # Check for the same function
            if chunk.get('fun') != low.get('fun'):
                continue
            # Pull out the pkg names!
            if 'pkgs' in chunk:
                pkgs.extend(chunk['pkgs'])
                chunk['__agg__'] = True
            elif 'name' in chunk:
                pkgs.append(chunk['name'])
                chunk['__agg__'] = True
    if pkgs:
        if 'pkgs' in low:
            low['pkgs'].extend(pkgs)
        else:
            low['pkgs'] = pkgs
    # The low has been modified and needs to be returned to the state
    # runtime for execution
    return low
