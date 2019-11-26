{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- if grains['kernel'] == 'Darwin' %}
  - python.wheel
{%- endif %}
{%- endif %}

install_ioflo:
  pip.installed:
    - name: ioflo
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
