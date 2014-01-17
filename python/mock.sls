include:
  - python.pip

mock:
  pip.installed:
    - require:
      - cmd: python-pip
