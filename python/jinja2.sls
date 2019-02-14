include:
  - gcc
  - python.pip

jinja2:
  pip.installed:
    - name: jinja2==2.7
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - require:
      - cmd: pip-install
      - pkg: gcc
