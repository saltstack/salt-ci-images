include:
  - gcc
  - python.pip

jinja2:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', None) }}
    - require:
      - cmd: python-pip
      - pkg: gcc
