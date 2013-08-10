include:
  - python.pip

SaltTesting:
  pip.installed:
    - source: git+https://github.com/saltstack/salt-testing.git#egg=SaltTesting
    - require:
      - pkg: python-pip

