{%- if grains['os_family'] == 'RedHat' %}
  {%- set rng_tools = 'rng-tools' %}
{%- elif grains['os_family'] == 'Debian' %}
  {%- set rng_tools = 'rng-tools5' %}
{%- else %}
  {%- set rng_tools = 'rng-tools' %}
{%- endif %}

rng-tools:
  pkg.installed:
    - name: {{ rng_tools }}
    - aggregate: True
