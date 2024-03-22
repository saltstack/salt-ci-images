{%- if grains['os'] in ['Ubuntu', 'Debian'] %}
  {%- set libxslt = "libxslt1-dev" %}
{%- elif grains['os'] in ['AlmaLinux', 'Fedora', 'Rocky', 'CentOS', 'CentOS Stream', 'VMware Photon OS'] or grains.os_family == 'Suse' %}
  {%- set libxslt = "libxslt-devel" %}
{%- else %}
  {%- set libxslt = "libxslt" %}
{%- endif %}

libxslt:
  pkg.installed:
    - name: {{ libxslt }}
