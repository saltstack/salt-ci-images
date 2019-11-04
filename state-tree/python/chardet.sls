include:
  - python.pip

chardet:
  pip.installed:
    - ignore_installed: true
    - require:
      - pip-install
