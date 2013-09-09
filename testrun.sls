{% from '_python.sls' import python with context %}

include:
  - git.salt

test_cmd:
  cmd.run:
    - name: '{{ python }} /testing/tests/runtests.py -v --run-destructive --sysinfo --no-colors --xml-out --html-out --coverage-html=/tmp/html-unitests-output --coverage-xml=/tmp/coverage.xml; code=$?; echo "Test Suite Exit Code: ${code}";'
    - order: last
    - require:
      - git: https://github.com/saltstack/salt.git
    - env:
      - XML_TESTS_OUTPUT_DIR: /tmp/xml-unitests-output
