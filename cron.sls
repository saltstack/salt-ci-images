{% if salt['grains.get']('os_family') == 'RedHat' %}
cronie:
  pkg.installed
{% endif %}
