{% if not ( pillar.get('py3', False) and grains['os'] == 'Windows' ) %}
{% if grains['os'] != 'Windows' %}
include:
  - python.pip
{% endif %}

supervisor:
  pip2.installed:
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
    {% if grains['os'] != 'Windows' %}
    - require:
      - cmd: pip-install
    {% endif %}
{% endif %}
