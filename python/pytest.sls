# PyTest 4.6.x are the last Py2 and Py3 releases
{%- set pytest_pinning = '>=4.6.1,<4.7' %}

{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

pytest:
  pip.installed:
    - name: 'pytest {{ pytest_pinning }}'
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
