include:
  - python.pip

apache-libcloud:
  pip.installed:
    - require:
      - cmd: python-pip
