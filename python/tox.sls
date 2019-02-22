{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

tox:
  pip.installed:
    - name: tox
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
