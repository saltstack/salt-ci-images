{%- from '../pkgs/python3.sls' import python3_dir with context %}
{%- if grains['cpuarch'].lower() == 'x86' %}
  {%- set bits = 32 %}
{%- else %}
  {%- set bits = 64 %}
{%- endif %}

include:
  - ..pkgs.python3


{%- for library in ("ssleay32.dll", "libeay32.dll", "libsodium.dll") %}
{{ library }}:
  file.managed:
    - name: '{{ python3_dir }}\\{{ library }}'
    - source: https://repo.saltstack.com/windows/dependencies/{{ bits }}/{{ library }}
    - skip_verify: true
    - require:
      - python3
{%- endfor %}
