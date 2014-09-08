{% from '_python.sls' import python with context %}
{% set test_transport = pillar.get('test_transport', 'zeromq') %}
{% set cloud_only = pillar.get('cloud_only', False) %}
{% set limited_run = pillar.get('limited_run') %}

test_cmd:
{%- if 'runtests.run' in salt %}
  runtests.run:
{%- else %}
  cmd.run:
{%- endif %}
{% if cloud_only == True %}
    - name: '{{ python }} /testing/tests/runtests.py -v --cloud-provider-tests --run-destructive --sysinfo --no-colors --xml=/tmp/xml-unitests-output --coverage-xml=/tmp/coverage.xml --transport={{ test_transport }}; code=$?; echo "Test Suite Exit Code: ${code}";'
{% elif limited_run != None %}
    - name: '{{ python }} /testing/tests/runtests.py -v --run-destructive -n {{ limited_run }} --sysinfo --no-colors --xml=/tmp/xml-unitests-output --coverage-xml=/tmp/coverage.xml --transport={{ test_transport }}; code=$?; echo "Test Suite Exit Code: ${code}";'
{% else %}
    - name: '{{ python }} /testing/tests/runtests.py -v --run-destructive --sysinfo --no-colors --xml=/tmp/xml-unitests-output --coverage-xml=/tmp/coverage.xml --transport={{ test_transport }}; code=$?; echo "Test Suite Exit Code: ${code}";'
{% endif %}
    - order: last
    - env:
      - XML_TESTS_OUTPUT_DIR: /tmp/xml-unitests-output
