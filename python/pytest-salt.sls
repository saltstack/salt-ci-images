{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

pytest-salt:
  pip.installed:
    - name: pytest-salt
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
