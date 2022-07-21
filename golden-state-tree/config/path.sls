append-usr-local-bin-to-path:
  file.append:
    - name: /root/.bash_profile
    - text: 'export PATH=/usr/local/bin:$PATH'
    - unless: 'echo $PATH | grep -q /usr/local/bin'
  environ.setenv:
    - name: PATH
    - value: '/usr/local/bin:{{ salt.cmd.run_stdout('echo $PATH', python_shell=True).strip() }}'
    - unless: 'echo $PATH | grep -q /usr/local/bin'
    - update_minion: True
