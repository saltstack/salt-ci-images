{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

shade:
  pip.installed:
    - name: shade
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
