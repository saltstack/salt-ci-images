include:
  - python.pip


hgtools:
  pip.installed:
  - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
  - require:
    - cmd: pip-install
