{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

install_jsonschema:
  pip.installed:
    - name: jsonschema==2.6.0
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
