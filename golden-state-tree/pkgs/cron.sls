{%- if grains['os'] == 'Debian' %}
cron:
  pkg.installed
{%- else %}
cronie:
  pkg.installed
{%- endif %}
