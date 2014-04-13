{% from '_python.sls' import python with context %}

test_cmd:
{%- if 'runtests.run' in salt %}
  runtests.run:
{%- else %}
  cmd.run:
{%- endif %}
    - name: '{{ salt['config.get']('virtualenv_path', '/SaViEn') }}/{{ python }} /testing/tests/runtests.py -v --xml=/tmp/xml-unitests-output; code=$?; echo "Test Suite Exit Code: ${code}";'
    - order: last
    - env:
      - XML_TESTS_OUTPUT_DIR: /tmp/xml-unitests-output
