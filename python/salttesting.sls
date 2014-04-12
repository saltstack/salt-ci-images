include:
  - python.pip

SaltTesting:
  pip.installed:
    - name: git+https://github.com/saltstack/salt-testing.git#egg=SaltTesting
    - bin_env: {{ config.get('virtualenv_path', None) }}
    - require:
      - cmd: python-pip

