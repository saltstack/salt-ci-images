{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

install_wheel:
  pip.installed:
    - name: wheel
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
