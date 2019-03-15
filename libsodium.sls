{%- if grains['os'] == 'Gentoo' %}
  {%- set libsodium = 'dev-libs/libsodium' %}
{%- elif grains['os'] in ('SUSE', 'openSUSE') %}
  {%- set libsodium = 'libsodium-devel' %}
{%- elif grains['os'] in ('Debian', 'Ubuntu') %}
  {%- set libsodium = 'libsodium-dev' %}
{%- else %}
  {%- set libsodium = 'libsodium' %}
{%- endif %}

libsodium:
  pkg.installed:
    - name: {{ libsodium }}
    - aggregate: True
