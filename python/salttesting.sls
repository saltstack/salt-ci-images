include:
  - python.pip

SaltTesting:
  pip.installed:
    - name: git+https://github.com/saltstack/salt-testing.git@dbe543789ceda0df3e299208293579ba178dc14c#egg=SaltTesting
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: python-pip

