include:
  - python.pip

SaltTesting:
  pip.installed:
    {# let's install 0.5.0 for now
    - name: git+https://github.com/saltstack/salt-testing.git#egg=SaltTesting
    #}
    - require:
      - pkg: python-pip

