{%- if grains['os_family'] == 'RedHat' %}
  {%- set openssl_dev = 'openssl-devel' %}
{%- elif grains['os_family'] == 'Suse' %}
  {%- set openssl_dev = 'libopenssl-devel' %}
{%- else %}
  {%- set openssl_dev = 'libssl-dev' %}
{%- endif %}

include:
  - pkgs.openssl

{{ openssl_dev }}:
  pkg.installed:
    - require:
      - openssl
    - aggregate: False
