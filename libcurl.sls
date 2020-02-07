{%- set libcurl_pkg = 'libcurl-devel' %}
{%- if grains['os_family'] == 'Debian' %}
  {%- set libcurl_pkg = 'libcurl4-openssl-dev' %}
{%- endif %}

# Arch ships libcurl dev files with the curl package
{%- if grains['os_family'] not in ('Arch',) %}
{{ libcurl_pkg }}:
  pkg.latest:
    - aggregate: True
{%- endif %}
