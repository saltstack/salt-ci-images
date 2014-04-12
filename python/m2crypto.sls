include:
  - gcc
  - swig
  - python.pip

m2crypto:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', None) }}
    - require:
      - cmd: python-pip
      - pkg: gcc
      - pkg: swig
