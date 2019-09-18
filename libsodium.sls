{%- if grains['os'] != 'Windows' %}
  {%- if grains['os'] == 'Gentoo' %}
    {%- set libsodium = 'dev-libs/libsodium' %}
  {%- elif grains['os'] in ('SUSE', 'openSUSE') %}
    {%- set libsodium = 'libsodium-devel' %}
# This is a fix to the following error:
# Problem: libsodium-devel-1.0.18-lp151.78.1.x86_64 requires libsodium23 = 1.0.18, but this requirement cannot be provided
#  not installable providers: libsodium23-1.0.18-lp151.78.1.x86_64[openSUSE-Leap-cloud-tools]
# Solution 1: install libsodium23-1.0.18-lp151.78.1.x86_64 (with vendor change)
#  openSUSE  -->  obs://build.opensuse.org/devel:libraries:c_c++
# Solution 2: do not install libsodium-devel-1.0.18-lp151.78.1.x86_64
# Solution 3: break libsodium-devel-1.0.18-lp151.78.1.x86_64 by ignoring some of its dependencies
'zypper mr -d openSUSE-Leap-Cloud-Tools':
  cmd.run:
    - order: 1
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
