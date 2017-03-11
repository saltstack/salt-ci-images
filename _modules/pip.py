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

# Import salt libs
from salt.utils import namespaced_function
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


__func_alias__ = {
    'list_': 'list'
}


def __virtual__():
    return True


def _get_pip_bin(bin_env, py3=False):
    '''
    Locate the pip binary, either from `bin_env` as a virtualenv, as the
    executable itself, or from searching conventional filesystem locations
    '''
    pip_bin_name = 'pip3' if py3 else 'pip2'
    if not bin_env:
        which_result = __salt__['cmd.which_bin']([pip_bin_name])
        if which_result is None:
            raise CommandNotFoundError('Could not find a `pip` binary')
        if salt.utils.is_windows():
            return which_result.encode('string-escape')
        return which_result

    # try to get pip bin from virtualenv, bin_env
    if os.path.isdir(bin_env):
        if salt.utils.is_windows():
            pip_bin = os.path.join(
                bin_env, 'Scripts', 'pip.exe').encode('string-escape')
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


def install(*args, **kwargs):  # pylint: disable=function-redefined
    pip_binary = _get_pip_bin(kwargs.get('bin_env'), py3=__pillar__.get('py3', False))
    kwargs['bin_env'] = pip_binary
    return pip_install(*args, **kwargs)


def list_(*args, **kwargs):
    return pip_list(*args, **kwargs)
