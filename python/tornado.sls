{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

{%- set pinned_pkg = 'tornado>=4.4.3,<4.5.0' %}

tornado:
  pip.installed:
    - name: {{ pinned_pkg }}
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
