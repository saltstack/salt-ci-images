{%- if grains['os_family'] == 'Arch' %}
lsb-release:
  pkg.installed
{%- endif %}
