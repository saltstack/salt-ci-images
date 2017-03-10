{%- if grains['os'] == 'CentOS' and grains['osrelease']|int == 7 %}
include:
  - python.pip

docker:
  pkg.installed:
    - aggregate: True

docker-py:
  pip.installed:
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    - require:
      - cmd: pip-install
{%- endif %}
