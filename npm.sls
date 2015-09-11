# Suse does not package npm separately
{% if grains['os_family'] == 'Suse' %}
  {%- set npm = 'nodejs' %}
{% elif grains['os'] == 'FreeBSD' %}
  {%- set npm = 'www/npm' %}
{% else %}
  {%- set npm = 'npm' %}
{% endif %}


npm:
  pkg.installed:
    - name: {{ npm }}

