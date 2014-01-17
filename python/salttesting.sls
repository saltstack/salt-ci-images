include:
  - python.pip

SaltTesting:
  pip.installed:
    - name: git+https://github.com/saltstack/salt-testing.git#egg=SaltTesting
    - require:
      - cmd: python-pip

