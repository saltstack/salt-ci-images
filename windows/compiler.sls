include:
  - windows.repo

{%- if salt['config.get']('py3', False) %}
  {%- set vcpp_compiler = 'ms-vcpp-2015-build-tools' %}
  {%- set compiler_bin_path = 'C:\\program files(x86)\\Microsoft Visual Studio 14.0\\VC\\bin' %}
{%- else %}
  {%- set vcpp_compiler = 'vcforpython27' %}
  {%- set compiler_bin_path = 'C:\\program files(x86)\\Microsoft Visual Studio 14.0\\VC\\bin' %}
{%- endif %}


vcpp-compiler:
  pkg.installed:
    - name: {{ vcpp_compiler }}
    - require:
      - win-pkg-refresh
    - order: 2
