include:
  - python.pip

nose:
  pip.installed:
    - require:
      - cmd: pip-install
