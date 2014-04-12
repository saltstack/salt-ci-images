include:
  - gcc
  - python.pip

pyzmq:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', None) }}
    - global-options:
      - fetch_libzmq
    - install-options:
      - --zmq=bundled
    - require:
      - cmd: python-pip
      - pkg: gcc
