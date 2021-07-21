{%- if grains['os_family'] == 'RedHat' %}
  {%- set openssl_dev = 'openssl-devel' %}
{%- elif grains['os'] in ('SUSE', 'openSUSE') %}
  {%- set openssl_dev = 'libopenssl-devel' %}
{%- else %}
  {%- set openssl_dev = 'libssl-dev' %}
{%- endif %}

{%- if grains['os'] in ('SUSE', 'openSUSE') %}
openssl-dev-remove-suse:
  pkg.removed:
    - name: libressl-devel-3.3.3-lp152.3.3.1.x86_64
{%- endif %}

openssl-dev-libs:
  pkg.installed:
    - name: {{ openssl_dev }}
    - aggregate: False
