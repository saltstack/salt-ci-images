{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

unittest2:
  pip.installed:
    - name: unittest2
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    {%- if grains['os'] != 'Windows' %}
    - require:
      - cmd: pip-install
    {%- endif %}
