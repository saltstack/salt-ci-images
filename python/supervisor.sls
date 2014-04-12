include:
  - python.pip

supervisor:
  pip.installed:
    - require:
      - cmd: python-pip
