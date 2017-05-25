profile:
  file.blockreplace:
    - name: /etc/profile
    - marker_start: '# ----- envs for salt-testing -----'
    - marker_end: '# ---------------------------------'
    - append_if_not_found: True
    - content: |
        [[ ${PATH} =~ "^/opt/salt/bin" ]] || export PATH="/opt/salt/bin:${PATH}"
        unset TMPDIR
