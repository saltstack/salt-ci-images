{% set fedora = True if grains['os'] == 'Fedora' else False %}
{% if grains['os'] not in ('Windows') %}
include:
  - python.pip
{% endif %}

setproctitle:
  pip.installed:
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - index_url: https://pypi-jenkins.saltstack.com/jenkins/develop
    - extra_index_url: https://pypi.python.org/simple
{% if grains['os'] not in ('Windows') %}
    - require:
      - cmd: pip-install
      {%- if fedora %}
      - pkg: redhat-rpm-config
      {% endif %}
{% endif %}
