include:
  - python.pip

bottle:
  pip.installed:
    - require:
      - cmd: python-pip
