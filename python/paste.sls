include:
  - python.pip

paste:
  pip.installed:
    - require:
      - cmd: python-pip
