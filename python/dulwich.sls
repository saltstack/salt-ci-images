{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

dulwich:
  pip.installed:
    - name: dulwich
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
