{%- if grains['os'] not in ('Windows',) %}
include:
  - gcc
  - python.pip
{%- endif %}

msgpack-python:
  pip.installed:
    - name: 'msgpack-python >= 0.4.2, != 0.5.5'
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
      - pkg: gcc
{%- endif %}
