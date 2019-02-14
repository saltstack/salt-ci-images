{% if grains['os'] != 'Windows' %}
include:
  - python.pip
{% endif %}

webtest:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
