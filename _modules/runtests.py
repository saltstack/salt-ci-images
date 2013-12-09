# -*- coding: utf-8 -*-
'''
    :codeauthor: :email:`Pedro Algarvio (pedro@algarvio.me)`
    :copyright: © 2013 by the UfSoft.org Team, see AUTHORS for more details.
    :license: BSD, see LICENSE for more details.


    runtests.py
    ~~~~~~~~~~~

    Simple module to stream the tests suite output since the current salt cmd
    module is unable.
'''

import os
import time
import salt.utils.vt


def run(cmd, env=None):

    if not env:
        env = {}

    run_env = os.environ.copy()
    run_env.update(env)

    terminal = salt.utils.vt.Terminal(
        cmd,
        shell=True,
        env=run_env,
        stream_stdout=True,
        stream_stderr=True,
        log_stdout=True,
        log_stderr=True
    )

    exiting = False
    while True:
        terminal.recv()

        if exiting:
            break

        if not terminal.isalive:
            exiting = True

        time.sleep(0.025)

    return terminal.exitstatus
