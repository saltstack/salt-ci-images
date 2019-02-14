include:
  - gcc
  - swig
  - python.pip

m2crypto:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - require:
      - cmd: pip-install
      - pkg: gcc
      - pkg: swig
