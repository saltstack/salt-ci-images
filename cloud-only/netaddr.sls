include:
  - python.pip

netaddr:
  pip.installed:
    - name: netaddr
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    - require:
      - cmd: pip-install
