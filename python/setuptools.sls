{%- if grains['os'] not in ('Windows') %}
include:
  - python.pip
{%- endif %}

setuptools:
  pip.installed:
    - name: "setuptools>=30"
{%- if grains['os'] not in ('Windows') %}
    - require:
      - cmd: pip-install
{%- endif %}
