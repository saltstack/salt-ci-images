include:
  - python.pip

profitbricks:
  pip.installed:
    - name: profitbricks
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    - require:
      - cmd: pip-install
