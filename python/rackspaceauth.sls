{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

rackspaceauth:
  pip.installed:
    - name: rackspaceauth
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
