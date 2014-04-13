include:
  - python.pip

SaltTesting:
  pip.installed:
    - name: git+https://github.com/saltstack/salt-testing.git#egg=SaltTesting
    {%- if salt['config.get']('virtualenv_path', None) is not None %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require:
      - cmd: python-pip

