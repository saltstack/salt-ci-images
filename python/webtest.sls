include:
  - python.pip

webtest:
  pip.installed:
    - require:
      - cmd: python-pip
