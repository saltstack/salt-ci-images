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
import sys
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
    terminal.wait()
    return terminal.exitstatus

    exiting = False
    while True:
        stdout, stderr = terminal.recv()
        if stdout:
            sys.stdout.write(stdout)
            sys.stdout.flush()

        if stderr:
            sys.stderr.write(stderr)
            sys.stderr.flush()

        if exiting:
            break

        if not terminal.isalive:
            exiting = True

        time.sleep(0.025)

    return terminal.exitstatus
