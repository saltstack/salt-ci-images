include:
  - gcc
  - python.pip

PyYAML:
  pip.installed:
    - name: PyYAML >= 3.12
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - require:
      - cmd: pip-install
      - pkg: gcc
