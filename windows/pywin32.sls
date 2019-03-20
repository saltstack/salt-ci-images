include:
  - python.pip

pywin32:
  pip.installed:
    - name: 'pywin32==224'
    - require:
      - pip-install
