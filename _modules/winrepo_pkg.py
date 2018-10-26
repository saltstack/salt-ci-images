'''
Extend win_pkg.install to allow win_repo package details to be defined in the
state calling install.
'''
import os
import logging
import types
import functools
import salt.utils

from salt.utils.functools import namespaced_function
import salt.modules.win_pkg
from salt.modules.win_pkg import *
from salt.ext.six.moves.urllib.parse import urlparse as _urlparse


PKG_DATA = {}
NAMESPACE_FUNCS = [
	'_get_repo_details',
	'_get_msiexec',
	'_get_latest_pkg_version',
	'get_repo_data',
]


for name in dir(salt.modules.win_pkg):
    attr = getattr(salt.modules.win_pkg, name)
    if isinstance(attr, types.FunctionType):
        if name in NAMESPACE_FUNCS:
            globals()[name] = salt.utils.namespaced_function(attr, globals())


def __virtual__():
    if salt.utils.is_windows():
        return True
    return (False, 'This module only works on Windows.')


def refresh_db(*args, **kwargs):
    '''
    Override refresh db and peform a no-op
    '''
    return


def list_pkgs(*args, **kwargs):
    '''
    Override list packages beause we do not expect to have a win_repo cloned
    yet.
    '''
    return {}


def _get_package_info_partial(name, **kwargs):
    '''
    Define package info via module level PKG_DATA attribute or via a pkg_data
    keyword argument passed to install.
    '''
    kw_win_repo = {}
    # Get a win_repo dict from the kwargs if passed, remove the key from the
    # kwargs in case we pass them to the original get_package_info function.
    if 'win_repo' in kwargs:
        kw_win_repo = kwargs.pop('win_repo')
    # If the original function is also passed, get pkg_data from it.
    if 'orig_func' in kwargs:
        orig_func = kwargs.pop('orig_func')
        pkg_data = orig_func(name, **kwargs)
        pkg_data.update(PKG_DATA)
    else:
        pkg_data = PKG_DATA
    pkg_data.update(kw_win_repo)
    return pkg_data[name]


def _get_package_info(name, **kwargs):
    raise NotImplementedError("STUBBED")


def install(*args, **kwargs):
    '''
    Winrepo install that can install packages without a win_repo, the package
    definition can passed to install via a win_repo keyword argument.
    '''
    global _get_package_info
    _orig_get_package_info = salt.modules.win_pkg._get_package_info
    pkg_install = namespaced_function(salt.modules.win_pkg.install, globals())
    try:
        _get_package_info = functools.partial(
            _get_package_info_partial,
            win_repo=kwargs.get('win_repo', {}),
            orig_func=namespaced_function(_orig_get_package_info, globals()),
        )
        return pkg_install(*args, **kwargs)
    finally:
        _get_package_info = _orig_get_package_info
