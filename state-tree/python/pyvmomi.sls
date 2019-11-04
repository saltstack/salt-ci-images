include:
  - python.requests
  - python.pip

pyvmomi:
  pip.installed:
    - name: pyvmomi
    - require:
      - requests
      - pip-install
