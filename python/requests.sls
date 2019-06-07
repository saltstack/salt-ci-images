{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

{%- if grains.get('pythonversion')[:2] < [3, 5] %}
  {%- set requests = 'requests<2.22.0'%}
{%- else %}
  {%- set requests = 'requests'%}
{%- endif %}

requests:
  pip.installed:
    - name: '{{ requests }}'
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
