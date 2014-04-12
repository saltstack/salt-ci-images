include:
  - gcc
  - python.pip

pycrypto:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', None) }}
    - require:
      - cmd: python-pip
      - pkg: gcc
