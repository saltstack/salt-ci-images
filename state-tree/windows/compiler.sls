{%- if salt['config.get']('py3', False) %}
  {%- set vcpp_compiler = 'ms-vcpp-2015-build-tools' %}
{%- else %}
  {%- set vcpp_compiler = 'vcforpython27' %}
{%- endif %}


vcpp-compiler:
  pkg.installed:
    - name: {{ vcpp_compiler }}
