include:
  - git

/testing:
  file.directory

https://github.com/saltstack/salt.git:
  git.latest:
    - rev: {{ pillar['git_commit'] }}
    - target: /testing
    - require:
      - file: /testing
      - sls: git

test_cmd:
  cmd.run:
    - name: python2 /testing/salt/tests/runtests.py
    - require:
      - git: https://github.com/saltstack/salt.git
