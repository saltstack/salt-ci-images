include:
  - gcc
  - swig
  - python.pip

m2crypto:
  pip.installed:
    - require:
      - cmd: pip-install
      - pkg: gcc
      - pkg: swig
