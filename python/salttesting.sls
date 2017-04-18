{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
  - gcc
{% endif %}

SaltTesting:
  pip.installed:
    - name: {{ pillar.get('salttesting_namespec', 'salttesting==2016.9.7') }}
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - upgrade: true
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
      - pkg: gcc
{% endif %}
