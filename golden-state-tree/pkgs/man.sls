{%- if grains.os_family == 'Suse' %}
  {%- set man = 'man' %}
{%- else %}
  {%- set man = 'man-db' %}
{%- endif %}

man:
  pkg.installed:
    - name: {{ man }}
