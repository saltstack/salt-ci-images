include:
  - git
  - python.salttesting
  - python.unittest2
  - python.mock

/testing:
  file.directory

https://github.com/saltstack/salt.git:
  git.latest:
    - rev: {{ pillar['git_commit'] }}
    - target: /testing
    - require:
      - file: /testing
      - pkg: git

test_cmd:
  cmd.run:
    - name: python2 /testing/tests/runtests.py
    - require:
      - git: https://github.com/saltstack/salt.git
      - pip: SaltTesting
      - pip: unittest2
      - pip: mock
