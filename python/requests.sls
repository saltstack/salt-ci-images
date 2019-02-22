{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

requests:
  pip.installed:
    - name: requests
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
