include:
  - gcc
  - python.pip

pyzmq:
  pip.installed:
    - name: pyzmq{{salt.pillar.get('pyzmq:version', '')}}
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    - global-options:
      - fetch_libzmq
    - install-options:
      - --zmq=bundled
    - require:
      - cmd: pip-install
      - pkg: gcc
