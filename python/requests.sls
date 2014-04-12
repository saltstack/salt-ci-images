include:
  - python.pip

requests:
  pip.installed:
    - bin_env: {{ config.get('virtualenv_path', None) }}
    - require:
      - cmd: python-pip
