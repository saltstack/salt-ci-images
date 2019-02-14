include:
  - gcc
  - python.pip

PyYAML:
  pip.installed:
    - name: PyYAML >= 3.12
    - require:
      - cmd: pip-install
      - pkg: gcc
