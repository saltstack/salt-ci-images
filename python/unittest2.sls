{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

unittest2:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
  {% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
  {% endif %}
