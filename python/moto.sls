include:
  - python.requests
{%- if grains['os'] not in ('Windows',) %}
  - python.pip
{%- endif %}

{%- set moto_version = 'moto==1.1.25' %}

moto:
  pip.installed:
    - name: moto
    - require:
      - requests
{%- if grains['os'] != 'Windows' %}
      - cmd: pip-install
{%- endif %}
