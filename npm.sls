{% set arch = True if grains['os_family'] == 'Arch' else False %}
{% set suse = True if grains['os_family'] == 'Suse' else False %}
{% set freebsd = True if grains['os'] == 'FreeBSD' else False %}
{% set macos = True if grains['os'] == 'MacOS' else False %}

# Suse does not package npm separately
{% if suse %}
  {%- set npm = 'npm4' %}
  {%- set nodejs = 'nodejs4' %}
{% elif freebsd %}
  {%- set npm = 'www/npm' %}
{% elif macos %}
  {%- set npm = 'node' %}
{% else %}
  {%- set npm = 'npm' %}
{% endif %}


npm:
  pkg.installed:
    - pkgs:
{% if suse %}
      - {{ nodejs }}
      - {{ npm }}
{% else %}
      - {{ npm }}
    - aggregate: True
{% endif %}

{# workaround for https://github.com/npm/npm/issues/19634 #}
{% if arch %}
libuv:
  pkg.installed:
    - reinstall: True
    - sources:
      - libuv: https://archive.archlinux.org/packages/l/libuv/libuv-1.18.0-1-x86_64.pkg.tar.xz
{% endif %}
