{%- if salt['grains.get']('os_family') in ('Arch', 'RedHat') %}
cronie:
  pkg.installed
{%- elif salt['grains.get']('os_family') == 'Debian' %}
cron:
  pkg.installed
{%- endif %}
