include:
  - gcc
  - python.pip

pyzmq:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    - global-options:
      - fetch_libzmq
    - install-options:
      - --zmq=bundled
    - require:
      - cmd: pip-install
      - pkg: gcc
