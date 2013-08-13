include:
  - git
  - python.salttesting
  - python.virtualenv
  {%- if tuple(grains.get('pythonversion')) < (2, 7) %}
  - python.unittest2
  {%- endif %}
  - python.mock
  - python.timelib

/testing:
  file.directory

https://github.com/saltstack/salt.git:
  git.latest:
    - rev: {{ pillar.get('git_commit', 'develop') }}
    - target: /testing
    - require:
      - file: /testing
      - pkg: git
      - pip: SaltTesting
      - pip: virtualenv
      {%- if tuple(grains.get('pythonversion')) < (2, 7) %}
      - pip: unittest2
      {%- endif %}
      - pip: mock
      - pip: timelib
