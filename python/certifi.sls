include:
  - python.pip

certifi:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    - upgrade: True
    - require:
      - cmd: pip-install
