{%- if grains['os_family'] == 'Debian' %}
  {%- set rng_tools = 'rng-tools5' %}
{%- else %}
  {%- set rng_tools = 'rng-tools' %}
{%- endif %}

rng_tools:
  pkg.installed:
    - name: {{ rng_tools }}
