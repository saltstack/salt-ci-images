# -*- coding: utf-8 -*-
'''
Module for managing locales on POSIX-like systems.

This can be removed when upgraded to using 2018.3.4
'''
from __future__ import absolute_import, print_function, unicode_literals

# Import python libs
import logging
import re
import os

try:
    import dbus
except ImportError:
    dbus = None

# Import Salt libs
import salt.utils.locales
import salt.utils.path
import salt.utils.platform
import salt.utils.systemd
from salt.ext import six
from salt.exceptions import CommandExecutionError

# Import localemod stuff

from salt.modules.localemod import *

log = logging.getLogger(__name__)

# Define the module's virtual name
__virtualname__ = 'locale'


def __virtual__():
    '''
    Exclude Windows OS.
    '''
    if salt.utils.platform.is_windows():
        return False, 'Cannot load locale module: windows platforms are unsupported'

    return __virtualname__


def _localectl_status():
    '''
    Parse localectl status into a dict.
    :return: dict
    '''
    if salt.utils.path.which('localectl') is None:
        raise CommandExecutionError('Unable to find "localectl"')

    ret = {}
    locale_ctl_out = (__salt__['cmd.run']('localectl status') or '').strip()
    ctl_key = None
    for line in locale_ctl_out.splitlines():
        if ': ' in line:  # Keys are separate with ":" and a space (!).
            ctl_key, ctl_data = line.split(': ')
            ctl_key = ctl_key.strip().lower().replace(' ', '_')
        else:
            ctl_data = line.strip()
        if not ctl_data:
            continue
        if ctl_key:
            if '=' in ctl_data:
                loc_set = ctl_data.split('=')
                if len(loc_set) == 2:
                    if ctl_key not in ret:
                        ret[ctl_key] = {}
                    ret[ctl_key][loc_set[0]] = loc_set[1]
            else:
                ret[ctl_key] = {'data': None if ctl_data == 'n/a' else ctl_data}
    if not ret:
        log.debug("Unable to find any locale information inside the following data:\n%s", locale_ctl_out)
        raise CommandExecutionError('Unable to parse result of "localectl"')

    return ret
