include:
  - python.pip

bottle:
  pip.installed:
    - require:
      - cmd: pip-install
