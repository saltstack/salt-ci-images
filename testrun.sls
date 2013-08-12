include:
  - git.salt

test_cmd:
  cmd.run:
    - name: '{{ python }} /testing/tests/runtests.py --run-destructive --sysinfo --no-colors -v; code=$?; echo "Test Suite Exit Code: ${code}";'
    - order: last
    - require:
      - git: https://github.com/saltstack/salt.git
