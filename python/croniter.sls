{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

croniter:
  pip.installed:
    - name: "croniter>=0.3.0,!=0.3.22"
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
