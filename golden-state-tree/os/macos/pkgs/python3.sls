python3:
  file.managed:
    - source: https://www.python.org/ftp/python/3.6.8/python-3.6.8-macosx10.6.pkg
    - name: /tmp/python-3.6.pkg
    - user: vagrant
    - group: wheel
    - skip_verify: True
    - onlyif: '[ ! -d /Library/Frameworks/Python.framework/Versions/3.6 ]'
  macpackage.installed:
    - name: /tmp/python-3.6.pkg
    - reload_modules: True
    - onlyif: '[ ! -d /Library/Frameworks/Python.framework/Versions/3.6 ]'

install-certs-py3:
  cmd.run:
    - name: /Applications/Python\ 3.6/Install\ Certificates.command
    - runas: vagrant

add-python3-to-path:
  file.append:
    - names:
      - /etc/paths.d/python:
        - text: '/Library/Frameworks/Python.framework/Versions/3.6/bin'
  environ.setenv:
    - name: PATH
    - value: '/Library/Frameworks/Python.framework/Versions/3.6/bin:{{ salt.cmd.run_stdout('echo $PATH', python_shell=True).strip() }}'
    - update_minion: True
