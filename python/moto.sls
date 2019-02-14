{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

{%- set moto_version = 'moto==1.1.25' %}

moto:
  pip.installed:
    - name: moto
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
