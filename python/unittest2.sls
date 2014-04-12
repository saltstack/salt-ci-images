include:
  - python.pip

unittest2:
  pip.installed:
    - bin_env: {{ config.get('virtualenv_path', None) }}
    - require:
      - cmd: python-pip
