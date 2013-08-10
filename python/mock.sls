include:
  - python.pip

mock:
  pip.installed:
    - require:
      - pkg: python-pip
