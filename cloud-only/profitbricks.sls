include:
  - python.pip

profitbricks:
  pip.installed:
    - name: profitbricks
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - require:
      - cmd: pip-install
