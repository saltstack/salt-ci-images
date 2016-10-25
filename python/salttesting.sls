include:
  - python.pip
  - gcc

SaltTesting:
  pip.installed:
    - name: {{ pillar.get('salttesting_namespec', 'salttesting==2016.7.22') }}
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - upgrade: true
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: pip-install
      - pkg: gcc

