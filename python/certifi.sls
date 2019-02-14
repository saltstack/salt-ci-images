include:
  - python.pip

certifi:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - upgrade: True
    - require:
      - cmd: pip-install
