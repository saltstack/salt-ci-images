{%- if grains['os_family'] == 'Debian' %}
  {%- set rust = 'rustc' %}
{%- else %}
  {%- set rust = 'rust' %}
{%- endif %}

rust:
  pkg.installed:
    - name: {{ rust }}
