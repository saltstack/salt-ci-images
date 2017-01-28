{% if grains['os'] not in ('Windows') %}
include:
  - python.pip
{% endif %}

six:
  pip.installed:
    - upgrade: true
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    {%- if salt['config.get']('pip_target', None)  %}
    - target: {{ salt['config.get']('pip_target') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
{% if grains['os'] not in ('Windows') %}
    - require:
      - cmd: pip-install
{% endif %}
