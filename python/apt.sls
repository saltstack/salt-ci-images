{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}

{% if os_family == 'Debian' and os_major_release == 8 -%}
python3-apt:
  pkg.installed
{%- endif %}
