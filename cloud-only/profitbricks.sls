include:
  - python.pip

profitbricks:
  pip.installed:
    - name: profitbricks
    - require:
      - cmd: pip-install
