{% from '_python.sls' import python with context %}
{% set test_transport = pillar.get('test_transport', 'zeromq') %}
{% set cloud_only = pillar.get('cloud_only', False) %}
{% set git_branch = pillar.get('git_branch', '') %}
{% set with_coverage = pillar.get('with_coverage', True) %}

test_cmd:
{%- if 'runtests.run' in salt %}
  runtests.run:
{%- else %}
  cmd.run:
{%- endif %}
{% if cloud_only == True %}
    - name: '{{ python }} /testing/tests/runtests.py -v --cloud-provider-tests --run-destructive --no-colors --xml=/tmp/xml-unittests-output{% if with_coverage %} --coverage-xml=/tmp/coverage.xml{% endif %} --transport={{ test_transport }}; code=$?; echo "Test Suite Exit Code: ${code}";'
{% else %}
    - name: '{{ python }} /testing/tests/runtests.py -v --run-destructive --no-colors{% if git_branch not in ('2014.1',) %} --ssh{% endif %} --xml=/tmp/xml-unittests-output{% if with_coverage %} --coverage-xml=/tmp/coverage.xml{% endif %} --transport={{ test_transport }}; code=$?; echo "Test Suite Exit Code: ${code}";'
{% endif %}
    - order: last
    - env:
      - XML_TESTS_OUTPUT_DIR: /tmp/xml-unittests-output
