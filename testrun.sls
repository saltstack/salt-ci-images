{% from '_python.sls' import python with context %}

include:
  - git.salt

test_cmd:
  cmd.run:
    - name: '{{ python }} /testing/tests/runtests.py --no-clean --run-destructive --sysinfo --no-colors -v -x; code=$?; echo "Test Suite Exit Code: ${code}";'
    - order: last
    - require:
      - git: https://github.com/saltstack/salt.git
