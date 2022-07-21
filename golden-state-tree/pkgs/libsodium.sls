{%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}
{%- if grains['os'] == 'Gentoo' %}
  {%- set libsodium = 'dev-libs/libsodium' %}
{%- elif grains['os_family'] == 'Suse' %}
  {%- set libsodium = 'libsodium-devel' %}
{%- elif grains['os'] in ('Debian', 'Ubuntu') %}
  {%- set libsodium = 'libsodium-dev' %}
{%- else %}
  {%- set libsodium = 'libsodium' %}
{%- endif %}

{%- if grains['os'] in ('AlmaLinux', 'CentOS', 'CentOS Stream', 'Amazon') %}
include:
  - os.centos-stream.pkgs.epel-release
{%- endif %}

{{ libsodium }}:
  pkg.installed
