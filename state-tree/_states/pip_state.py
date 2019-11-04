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
import logging
import pkg_resources

# Import salt libs
import salt.utils.args
import salt.states.pip_state
from salt.states.pip_state import *  # pylint: disable=wildcard-import,unused-wildcard-import
from salt.states.pip_state import installed as pip_state_installed
from salt.states.pip_state import removed as pip_state_removed
from salt.utils.functools import namespaced_function

# We need to re-import some of the pip imports
try:
    from pip._internal.req.constructors import _strip_extras
    from pip._internal.download import is_archive_file, is_url, url_to_path
    from pip._vendor.packaging.requirements import InvalidRequirement, Requirement
except ImportError:
    pass

__virtualname__ = 'pip'

log = logging.getLogger(__name__)

# Let's namespace the pip_state_installed function
pip_state_installed = namespaced_function(pip_state_installed, globals())  # pylint: disable=invalid-name
pip_state_removed = namespaced_function(pip_state_removed, globals())  # pylint: disable=invalid-name
uptodate = namespaced_function(salt.states.pip_state.uptodate, globals())  # pylint: disable=invalid-name
removed = namespaced_function(salt.states.pip_state.removed, globals())  # pylint: disable=invalid-name
_from_line = namespaced_function(salt.states.pip_state._from_line, globals())  # pylint: disable=invalid-name
_check_if_installed = namespaced_function(salt.states.pip_state._check_if_installed, globals())  # pylint: disable=invalid-name
_check_pkg_version_format = namespaced_function(salt.states.pip_state._check_pkg_version_format, globals())  # pylint: disable=invalid-name
_fulfills_version_spec = namespaced_function(salt.states.pip_state._fulfills_version_spec, globals())  # pylint: disable=invalid-name
_find_key = namespaced_function(salt.states.pip_state._find_key, globals())  # pylint: disable=invalid-name


def __virtual__():
    if 'pip.list' in __salt__:
        return __virtualname__
    return False


def removed(name, **kwargs):
    virtualenv_path = __salt__['config.get']('virtualenv_path', None)
    log.debug(
        'Searching for pip binary using bin_env(%s) or virtualenv_path(%s)',
        kwargs.get('bin_env'),
        virtualenv_path
    )
    bin_env = __salt__['pip.get_pip_bin'](
        kwargs.get('bin_env') or __salt__['config.get']('virtualenv_path', None),
    )
    if isinstance(bin_env, list):
        bin_env = bin_env[0]
    log.warning('pip binary found: %s', bin_env)
    kwargs.setdefault('cwd', __salt__['config.get']('pip_cwd', None))
    kwargs.update(
        bin_env=bin_env)
    kwargs = salt.utils.args. clean_kwargs(**kwargs)
    return pip_state_removed(name, **kwargs)

def installed(name, **kwargs):
    index_url = kwargs.pop('index_url', None)
    if index_url is None:
        index_url = 'https://artifactory.saltstack.net/artifactory/api/pypi/pypi-open/simple'
    extra_index_url = kwargs.pop('extra_index_url', None)
    if extra_index_url is None:
        extra_index_url = 'https://pypi.python.org/simple'

    virtualenv_path = __salt__['config.get']('virtualenv_path', None)
    log.debug(
        'Searching for pip binary using bin_env(%s) or virtualenv_path(%s)',
        kwargs.get('bin_env'),
        virtualenv_path
    )
    bin_env = __salt__['pip.get_pip_bin'](
        kwargs.get('bin_env') or __salt__['config.get']('virtualenv_path', None),
    )
    if isinstance(bin_env, list):
        bin_env = bin_env[0]
    log.warning('pip binary found: %s', bin_env)

    # Complementary set of cwd and target
    kwargs.setdefault('cwd', __salt__['config.get']('pip_cwd', None))
    kwargs.setdefault('target', __salt__['config.get']('pip_target', None))

    kwargs.update(
        index_url=index_url,
        extra_index_url=extra_index_url,
        bin_env=bin_env)
    kwargs = salt.utils.args.clean_kwargs(**kwargs)
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


def tornado(name, cwd=None, bin_env=None):
    ret = {
        'name': 'pip install tornado{version}'.format(version=name),
        'result': True,
        'changes': {},
    }
    if cwd is None:
         cwd = __salt__['config.get']('pip_cwd', None)
    pip_bin = __salt__['pip.get_pip_bin'](
        bin_env or __salt__['config.get']('virtualenv_path', None),
    )
    if isinstance(pip_bin, list):
        pip_bin = pip_bin[0]

    ret['comment'] = __salt__['cmd.run'](
        cmd='{pip} install -U --upgrade-strategy only-if-needed tornado{version}'.format(
            pip=pip_bin,
            version=name
        ),
        cwd=cwd or None,
    )
    return ret
