include:
  - pip

virtualenv:
  pip.installed:
    - require:
      - pkg: python-pip
