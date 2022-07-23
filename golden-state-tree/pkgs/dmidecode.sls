{%- if grains['os'] == 'MacOS' %}
  {%- set dmidecode = 'cavaliercoder/dmidecode/dmidecode' %}
{%- else %}
  {%- set dmidecode = 'dmidecode' %}
{%- endif %}

dmidecode:
  pkg.installed:
    - name: {{ dmidecode }}
