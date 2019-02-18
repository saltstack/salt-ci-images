include:
  - python.pip

clustershell:
  pip.installed:
    - name: clustershell
    - require:
      - cmd: pip-install
