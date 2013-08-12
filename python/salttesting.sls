include:
  - python.pip

SaltTesting:
  pip.installed:
    - editable: git+https://github.com/saltstack/salt-testing.git#egg=SaltTesting
    - require:
      - pkg: python-pip

