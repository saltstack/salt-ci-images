#!/usr/bin/env python2.7
import salt.client
import salt.config

__opts__ = salt.config.minion_config('/tmp/kitchen/etc/salt/minion')
__opts__['file_client'] = 'local'
caller = salt.client.Caller(mopts=__opts__)
if caller.cmd('config.get', 'py3', False):
    print('python3')
else:
    print('python2.7')
