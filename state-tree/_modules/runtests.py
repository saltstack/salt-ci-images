# -*- coding: utf-8 -*-
'''
    :codeauthor: :email:`Pedro Algarvio (pedro@algarvio.me)`
    :copyright: © 2014 by the UfSoft.org Team, see AUTHORS for more details.
    :license: BSD, see LICENSE for more details.


    runtests.py
    ~~~~~~~~~~~

    Simple module to stream the tests suite output since the current salt cmd
    module is unable.
'''

# Import python libs
import os
import sys
import time

# Import salt libs
import salt.utils.vt
import salt.utils.event


def run(minion_id,
        sysinfo=False,
        names=None,
        run_destructive=False,
        module_tests=False,
        state_tests=False,
        client_tests=False,
        shell_tests=False,
        runner_tests=False,
        loader_tests=False,
        unit_tests=False,
        outputter_tests=False,
        ssh_tests=False,
        verbose=0,
        output_columns=80,
        tests_logfile=None,
        xml_out=None,
        no_report=False,
        no_colors=False,
        coverage=False,
        no_processes_coverage=False,
        coverage_xml=None,
        coverage_html=None,
        no_clean=False,
        runtests_script_path='/testing/tests/runtests.py'
        ):
    '''

    Run tests on minion

    :param minion_id: The minion ID where runtests will be executed
    :param sysinfo: Print some system information.
    :param names: Comma delimited list of test names to run
    :param run_destructive: Run destructive tests. These tests can include adding or removing users from your system
                            for example.
    :param module_tests: Run tests for modules
    :param state_tests: Run tests for states
    :param client_tests: Run tests for client
    :param shell_tests: Run shell tests
    :param runner_tests: Run runner tests
    :param loader_tests: Run loader tests
    :param unit_tests: Run loader tests
    :param outputter_tests: Run outputter tests
    :param ssh_tests: Run ssh tests
    :param verbose: Verbosity level(0-3)
    :param output_columns: Number of maximum columns to use on the output
    :param tests_logfile: The path to the tests suite logging logfile
    :param xml_out: XML tests output directory
    :param no_report: Do NOT show the overall tests result
    :param no_colors: Disable color printing
    :param coverage: Run tests and report code coverage
    :param no_processes_coverage: Do not track subprocess and/or multiprocessing processes
    :param coverage_xml: If provided, the path to where a XML report of the code coverage will be written to
    :param coverage_html: The directory where the generated HTML coverage report will be saved to. The directory,
                          if existing, will be deleted before the report is generated.
    :param runtests_script_path: The script to tests/runtscript.py
    :param no_clean: Don't clean up test environment before and after the tests suite execution
    :returns: !?!?!?

    '''

    cmd = [__grains__['pythonexecutable'], runtests_script_path]
    if sysinfo:
        cmd.append('--sysinfo')
    if names:
        cmd.extend(['--name={0}'.format(name) for name in names])
    if run_destructive:
        cmd.append('--run-destructive')
    if module_tests:
        cmd.append('--module')
    if state_tests:
        cmd.append('--state')
    if client_tests:
        cmd.append('--client')
    if shell_tests:
        cmd.append('--shell')
    if runner_tests:
        cmd.append('--runner')
    if loader_tests:
        cmd.append('--loader')
    if unit_tests:
        cmd.append('--unit')
    if outputter_tests:
        cmd.append('--outputter')
    if ssh_tests:
        cmd.append('--ssh')
    if verbose:
        cmd.append('-{0}'.format('v' * verbose))
    cmd.append('--output-columns={0}'.format(output_columns))
    if tests_logfile:
        cmd.append('--tests-logfile={0}'.format(tests_logfile))
    if xml_out:
        cmd.append('--xml-out={0}'.format(xml_out))
    if no_report:
        cmd.append('--no-report')
    if no_colors:
        cmd.append('--no-color')
    if coverage:
        cmd.append('--coverage')
    if no_processes_coverage:
        cmd.append('--no-processes-coverage')
    if coverage_xml:
        cmd.append('--coverage-xml={0}'.format(coverage_xml))
    if coverage_html:
        cmd.append('--coverage-html={0}'.format(coverage_html))
    if no_clean:
        cmd.append('--no-clean')


    terminal = salt.utils.vt.Terminal(
        cmd,
        #shell=True,
        stream_stdout=False,
        stream_stderr=False,
        log_stdout=True,
        log_stderr=True
    )
    #terminal.wait()
    #return terminal.exitstatus

    exiting = False
#    _stdout_buffer = ''
#    _stderr_buffer = ''
#    while True:
#        stdout, stderr = terminal.recv(2048)
#        _stdout_buffer += stdout
#        _stderr_buffer += stderr
#        if _stdout_buffer:
#            stdout = _stdout_buffer
#            if '\n' in stdout:
#                _stdout_buffer = stdout[stdout.rindex('\n') + 1:]
#                stdout = stdout[:stdout.rindex('\n') + 1]
#            __salt__['event.fire_master']({'stdout': stdout}, 'runtests/run/{0}'.format(minion_id))
#
#        if _stderr_buffer:
#            stderr = _stderr_buffer
#            if '\n' in stderr:
#                _stderr_buffer = stderr[stderr.rindex('\n') + 1:]
#                stderr = stderr[:stderr.rindex('\n') + 1]
#            __salt__['event.fire_master']({'stderr': stderr}, 'runtests/run/{0}'.format(minion_id))

    while True:
        stdout, stderr = terminal.recv(2048)
        if stdout:
            __salt__['event.fire_master']({'stdout': stdout}, 'runtests/run/{0}'.format(minion_id))

        if stderr:
            __salt__['event.fire_master']({'stderr': stderr}, 'runtests/run/{0}'.format(minion_id))

        if exiting:
            break

        if not terminal.isalive():
            exiting = True

        time.sleep(0.0025)

    __salt__['event.fire_master']({'exitstatus': terminal.exitstatus}, 'runtests/run/{0}'.format(minion_id))
    return terminal.exitstatus
