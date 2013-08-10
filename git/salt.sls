{% if grains['os'] == 'Arch' %}
  {% set python = 'python2' %}
{% else %}
  {% set python = 'python' %}
{% endif %}

include:
  - git
  - python.salttesting
  - python.virtualenv
  - python.unittest2
  - python.mock
  - python.timelib

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
    - name: {{ python }} /testing/tests/runtests.py -v --run-destructive --sysinfo
    - require:
      - git: https://github.com/saltstack/salt.git
      - pip: SaltTesting
      - pip: virtualenv
      - pip: unittest2
      - pip: mock
      - pip: timelib
