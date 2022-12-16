{%- if grains['os_family'] == 'Debian' %}
  {%- set xz = 'xz-utils' %}
{%- else %}
  {%- set xz = 'xz' %}
{%- endif %}

xz:
  pkg.installed:
    - name: {{ xz }}
