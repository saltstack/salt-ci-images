include:
  - python.pip

SaltTesting:
  pip.installed:
    - require: pkg: python-pip

