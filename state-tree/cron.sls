{%- if salt['grains.get']('os_family') in ('Arch', 'RedHat') %}
cronie:
  pkg.installed
{%- endif %}
