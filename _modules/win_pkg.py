# -*- coding: utf-8 -*-
'''
    win_pkg
    ~~~~~~~

    Custom win_pkg.install which fixes a bug where extra_install_flags is not passed
    because install gets pkgs.
'''

# Import python libs
from __future__ import absolute_import
import types
import logging

# Import salt libs
try:
    from salt.utils.functools import namespaced_function
except (ImportError, AttributeError):
    from salt.utils import namespaced_function
try:
    from salt.utils.platform import is_windows
except (ImportError, AttributeError):
    from salt.utils import is_windows
import salt.modules.win_pkg
from salt.modules.win_pkg import *  # pylint: disable=wildcard-import,unused-wildcard-import
from salt.modules.win_pkg import install as win_pkg_install

# Import 3rd Party libs
import salt.ext.six as six
# pylint: disable=import-error,no-name-in-module
from salt.ext.six.moves.urllib.parse import urlparse as _urlparse, urlsplit, uses_params, ParseResult

# Let's namespace the pip_install function
win_pkg_install = namespaced_function(win_pkg_install, globals())  # pylint: disable=invalid-name

# Let's namespace all other functions from the pip module
for name in dir(salt.modules.win_pkg):
    attr = getattr(salt.modules.win_pkg, name)
    if isinstance(attr, types.FunctionType):
        if attr in ('install',):
            continue
        globals()[name] = namespaced_function(attr, globals())


__virtualname__ = 'pkg'


def __virtual__():
    '''
    Set the virtual pkg module if the os is Windows
    '''
    if is_windows():
        return __virtualname__
    return (False, "Module win_pkg: module only works on Windows systems")


def install(name=None, refresh=False, pkgs=None, **kwargs):
    if pkgs and len(pkgs) == 1:
        log.warning('PKGS: %s', pkgs)
        for pkg, version in six.iteritems(pkgs[0]):
            log.debug('PKG: %s  //  Details: %s', pkg, version)
            name = pkg
            kwargs_version = kwargs.get('version')
            if not kwargs_version or kwargs_version != version:
                kwargs['version'] = version
        pkgs = None
    return win_pkg_install(name=name, refresh=refresh, pkgs=pkgs, **kwargs)
