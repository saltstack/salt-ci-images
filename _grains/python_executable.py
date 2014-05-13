# -*- coding: utf-8 -*-
'''
    :codeauthor: :email:`Pedro Algarvio (pedro@algarvio.me)`
    :copyright: © 2014 by the SaltStack Team, see AUTHORS for more details.
    :license: Apache 2.0, see LICENSE for more details.


    python_bin
    ~~~~~~~~~~
'''

# Import python libs
import sys


def python_executable():
    '''
    Return the system's python binray
    '''
    return {'pythonexecutable', sys.executable}
