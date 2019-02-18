include:
  - python.pip

paste:
  pip.installed:
    - require:
      - cmd: pip-install
