{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

unittest-xml-reporting:
  pip.installed:
    - name: 'unittest-xml-reporting==2.2.1'
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
