{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

dnspython:
  pip.installed:
    - name: dnspython
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
