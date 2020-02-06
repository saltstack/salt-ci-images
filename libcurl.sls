{%- set libcurl_pkg = 'libcurl-devel' %}
{%- if grains['os_family'] == 'Debian' %}
  {%- set libcurl_pkg = 'libcurl4-openssl-dev' %}
{%- endif %}

{{ libcurl_pkg }}:
  pkg.latest:
    - aggregate: True
