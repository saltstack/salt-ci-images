{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

mock:
  pip.installed:
    - name: mock
    {%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
    {%- endif %}
