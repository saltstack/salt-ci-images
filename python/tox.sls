include:
  - python.pip

tox:
  pip.installed:
    - name: tox
    - require:
      - cmd: pip-install
