{%- if grains['os'] != 'Windows' %}
  {%- if grains['os'] == 'Gentoo' %}
    {%- set libsodium = 'dev-libs/libsodium' %}
  {%- elif grains['os'] in ('SUSE', 'openSUSE') %}
    {%- set libsodium = 'libsodium-devel' %}
  {%- elif grains['os'] in ('Debian', 'Ubuntu') %}
    {%- set libsodium = 'libsodium-dev' %}
  {%- else %}
    {%- set libsodium = 'libsodium' %}
  {%- endif %}

  {%- if grains['os'] in ('CentOS', 'Amazon') %}
include:
  - epel
  {%- endif %}

libsodium:
  pkg.installed:
    - name: {{ libsodium }}
    - aggregate: True

{%- else %}

include:
  - python3
  - python27

  {%- set python3_dir = 'c:\\\\Python35' %}
  {%- set python2_dir = 'c:\\\\Python27' %}
  {%- if grains['cpuarch'].lower() == 'x86' %}
    {%- set bits = 32 %}
  {%- else %}
    {%- set bits = 64 %}
  {%- endif %}

py2-libsodium:
  file.managed:
    - name: '{{ python2_dir }}\\libsodium.dll'
    - source: https://repo.saltstack.com/windows/dependencies/{{ bits }}/libsodium.dll
    - skip_verify: true
    - require:
      - python2

py3-libsodium:
  file.managed:
    - name: '{{ python3_dir }}\\libsodium.dll'
    - source: https://repo.saltstack.com/windows/dependencies/{{ bits }}/libsodium.dll
    - skip_verify: true
    - require:
      - python3

libsodium:
  test.succeed_without_changes:
    - require:
      - py2-libsodium
      - py3-libsodium
{%- endif %}
