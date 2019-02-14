include:
  - python.pip

netaddr:
  pip.installed:
    - name: netaddr
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - require:
      - cmd: pip-install
