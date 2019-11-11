{%- set py3_vcpp_compiler = 'ms-vcpp-2015-build-tools' %}
{%- set py2_vcpp_compiler = 'vcforpython27' %}

include:
  - python27
  - python3

py2-vcpp-compiler:
  pkg.installed:
    - name: {{ py2_vcpp_compiler }}
    - require:
      - python2

py3-vcpp-compiler:
  pkg.installed:
    - name: {{ py3_vcpp_compiler }}
    - require:
      - python3

vcpp-compiler:
  test.succeed_without_changes:
    - require:
      - py2-vcpp-compiler
      - py3-vcpp-compiler
