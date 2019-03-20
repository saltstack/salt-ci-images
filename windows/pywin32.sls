include:
  - python.pip

pywin32:
  pip.installed:
    - name: 'pywin32==223'
    - require:
      - pip-install
