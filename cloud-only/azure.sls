include:
  - python.pip

azure:
  pip.installed:
    - name: azure
    - require:
      - cmd: pip-install
