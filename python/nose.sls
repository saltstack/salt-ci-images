include:
  - python.pip

nose:
  pip.installed:
    - bin_env: {{ config.get('virtualenv_path', None }}
    - require:
      - cmd: python-pip
