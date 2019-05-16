include:
  - python.requests
{%- if grains['os'] not in ('Windows',) %}
  - python.pip
{%- endif %}

pyvmomi:
  pip.installed:
    - name: pyvmomi
    - require:
      - requests
{%- if grains['os'] != 'Windows' %}
      - cmd: pip-install
{%- endif %}
