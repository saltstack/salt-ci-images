# -*- coding: utf-8 -*-
'''
    :codeauthor: :email:`Pedro Algarvio (pedro@algarvio.me)`
    :copyright: © 2014 by the SaltStack Team, see AUTHORS for more details.
    :license: Apache 2.0, see LICENSE for more details.


    python_bin
    ~~~~~~~~~~
'''


def python_executable():
    '''
    Return the system's python binray
    '''
    if __grains__['os'] == 'Arch':
        return {'pythonexecutable', 'python2'}

    if __grains__['os_family'] == 'RedHat' and __grains__['osmajorrelease'][0] == '5':
        return {'pythonexecutable', 'python2'}

    return {'pythonexecutable', 'python'}
