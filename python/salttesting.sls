include:
  - python.pip

SaltTesting:
  pip.installed:
    - name: git+https://github.com/saltstack/salt-testing.git@b193a8ce54c2a08010788489ce0b1539936a0133#egg=SaltTesting
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: python-pip

