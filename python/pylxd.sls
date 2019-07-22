include:
  - python.requests
{%- if grains['os'] not in ('Windows',) %}
  - python.pip
{%- endif %}

pylxd:
  pip.installed:
    - name: 'pylxd>=2.2.5'
    - require:
      - requests
{%- if grains['os'] not in ('Windows',) %}
      - cmd: pip-install
{%- endif %}
