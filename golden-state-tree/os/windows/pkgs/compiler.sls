{%- set py3_vcpp_compiler = 'ms-vcpp-2015-build-tools' %}

include:
  - .python3

py3-vcpp-compiler:
  pkg.installed:
    - name: {{ py3_vcpp_compiler }}
    - require:
      - python3

vcpp-compiler:
  test.succeed_without_changes:
    - require:
      - py3-vcpp-compiler
