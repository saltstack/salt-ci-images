include:
  - gcc
  - python.pip

PyYAML:
  pip.installed:
    - name: PyYAML >= 3.12
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    - require:
      - cmd: pip-install
      - pkg: gcc
