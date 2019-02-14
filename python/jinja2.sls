include:
  - gcc
  - python.pip

jinja2:
  pip.installed:
    - name: jinja2==2.7
    - require:
      - cmd: pip-install
      - pkg: gcc
