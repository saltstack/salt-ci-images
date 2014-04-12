include:
  - python.pip

webtest:
  pip.installed:
    - bin_env: {{ config.get('virtualenv_path', None) }}
    - require:
      - cmd: python-pip
