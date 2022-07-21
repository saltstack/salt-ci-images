{%- set libcurl_pkg = ['libcurl-devel'] %}
{%- if grains['os'] == 'VMware Photon OS' %}
  {%- set libcurl_pkg = ['curl-devel'] %}
{%- elif grains['os_family'] == 'Debian' %}
  {%- set libcurl_pkg = ['libcurl4-openssl-dev', 'libssl-dev', 'libgnutls28-dev'] %}
{%- endif %}

libcurl-and-pycurl-deps:
  pkg.latest:
    - pkgs:
  {%- for pkg in libcurl_pkg %}
      - {{ pkg }}
  {%- endfor %}
