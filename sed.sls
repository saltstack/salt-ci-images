{%- if grains['os'] == 'FreeBSD' %}
  {%- set sed = 'gsed' %}
{%- else %}
  {%- set sed = 'sed' %}
{%- endif %}

{%- if grains['os'] in ('Windows') %}
include:
  - python.pip
  {%- set install_method = 'pip.installed' %}
{%- else %}
  {%- set install_method = 'pkg.installed' %}
{%- endif %}

sed:
  {{ install_method }}:
    - name: {{ sed }}
    {%- if install_method == 'pkg.installed' %}
    - aggregate: True
    - require:
      - cmd: pip-install
    {%- endif %}
