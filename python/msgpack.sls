include:
  - gcc
  - python.pip

msgpack-python:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', None) }}
    - require:
      - cmd: python-pip
      - pkg: gcc
