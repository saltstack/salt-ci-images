{%- set salt_dir = salt['config.get']('python_install_dir', 'c:\\salt').rstrip('\\') %}
{%- set scripts_dir = salt_dir + '\\bin\\Scripts' %}
{%- set site_packages = salt_dir + '\\Lib\site-packages' %}
{%- if grains['cpuarch'].lower() == 'x86' %}
  {%- set bits = 32 %}
{%- else %}
  {%- set bits = 64 %}
{%- endif %}

{%- set dlls = ("libeay32.dll", "ssleay32.dll", "OpenSSL_License.txt", "msvcr120.dll", "libsodium.dll") %}

include:
  {%- if salt['config.get']('py3', False) %}
  - python3
  {%- else %}
  - python27
  {%- endif %}

{%- for fname in dlls %}
download-{{ fname }}:
  file.managed:
    - name: '{{ salt_dir }}\\{{ fname }}'
    - source: https://repo.saltstack.com/windows/dependencies/{{ bits }}/{{ fname }}
    - skip_verify: true
    - require:
    {%- if salt['config.get']('py3', False) %}
      - python3
    {%- else %}
      - python2
    {%- endif %}
    - order: 2
{%- endfor %}
