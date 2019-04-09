{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

pyvmomi:
  pip.installed:
    - name: pyvmomi
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
