#!/usr/bin/env python
import salt.client
import salt.config

__opts__ = salt.config.minion_config('/tmp/kitchen/etc/salt/minion')
__opts__['file_client'] = 'local'
caller = salt.client.Caller(mopts=__opts__)
if caller.cmd('config.get', 'py3', False):
    print('python3')
elif caller.cmd('config.get', 'os_family') == 'RedHat' and int(caller.cmd('config.get', 'osmajorrelease')) == 6:
    print('python2.7')
else:
    print('python2')
