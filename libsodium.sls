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

libsodium:
  pkg.installed:
    - name: {{ libsodium }}
    - aggregate: True

{%- else %}

include:
  {%- if pillar.get('py3', False) %}
  - python3
    {%- set python_dir = 'c:\\\\Python35' %}
  {%- else %}
  - python27
    {%- set python_dir = 'c:\\\\Python27' %}
  {%- endif %}

{%- if grains['cpuarch'].lower() == 'x86' %}
  {%- set bits = 32 %}
{%- else %}
  {%- set bits = 64 %}
{%- endif %}

libsodium:
  file.managed:
    - name: '{{ python_dir }}\\libsodium.dll'
    - source: https://repo.saltstack.com/windows/dependencies/{{ bits }}/libsodium.dll
    - skip_verify: true
    - require:
    {%- if pillar.get('py3', False) %}
      - python3
    {%- else %}
      - python2
    {%- endif %}
{%- endif %}
