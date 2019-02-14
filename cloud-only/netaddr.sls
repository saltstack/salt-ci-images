include:
  - python.pip

netaddr:
  pip.installed:
    - name: netaddr
    - require:
      - cmd: pip-install
