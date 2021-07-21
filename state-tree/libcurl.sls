{%- set libcurl_pkg = ['libcurl-devel'] %}
{%- if grains['os'] == 'VMware Photon OS' %}
  {%- set libcurl_pkg = ['curl-devel'] %}
{%- elif grains['os_family'] == 'Debian' %}
  {%- set libcurl_pkg = ['libcurl4-openssl-dev', 'libssl-dev', 'libgnutls28-dev'] %}
{%- endif %}

# Arch ships libcurl dev files with the curl package
{%- if grains['os_family'] not in ('Arch',) %}
libcurl_and_pycurl_deps:
  pkg.latest:
    - aggregate: True
    - pkgs:
  {%- for pkg in libcurl_pkg %}
      - {{ pkg }}
  {%- endfor %}
{%- endif %}
