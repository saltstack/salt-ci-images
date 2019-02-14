include:
  - python.pip

certifi:
  pip.installed:
    - upgrade: True
    - require:
      - cmd: pip-install
