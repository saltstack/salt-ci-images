{%- if grains['os_family'] == 'RedHat' or grains['os'] == 'openSUSE' %}
  {%- set libcurl_pkg = 'libcurl-devel' %}
{%- elif grains['os_family'] == 'Debian' %}
  {%- set libcurl_pkg = 'libcurl4-openssl-dev' %}
{%- endif %}

{{ libcurl_pkg }}:
  pkg.latest:
    - aggregate: True
