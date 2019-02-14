include:
  - python.pip

azure:
  pip.installed:
    - name: azure
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - require:
      - cmd: pip-install
