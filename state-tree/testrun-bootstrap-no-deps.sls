{%- from '_python.sls' import python with context %}

test_cmd:
{%- if 'runtests.run' in salt %}
  runtests.run:
{%- else %}
  cmd.run:
{%- endif %}
    - name: '{{ salt['config.get']('virtualenv_path', '/SaViEn') }}/bin/{{ python }} /testing/tests/runtests.py -v --xml=/tmp/xml-unittests-output; code=$?; echo "Test Suite Exit Code: ${code}";'
    - order: last
    - env:
      - XML_TESTS_OUTPUT_DIR: /tmp/xml-unittests-output
