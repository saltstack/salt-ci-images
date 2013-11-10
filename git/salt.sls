include:
  - git
  - patch
  {%- if grains['os_family'] not in ('FreeBSD',) %}
  - subversion
  {%- endif %}
  - python.salttesting
  - python.virtualenv
  {%- if grains.get('pythonversion')[:2] < [2, 7] %}
  - python.unittest2
  {%- endif %}
  {%- if grains['os'] == 'openSUSE' %}
  {#- Yes! openSuse ships xml as separate package #}
  - python.xml
  {%- endif %}
  - python.mock
  - python.timelib
  - python.coverage
  - python.unittest-xml-reporting

/testing:
  file.directory

https://github.com/saltstack/salt.git:
  git.latest:
    - rev: {{ pillar.get('git_commit', 'develop') }}
    - target: /testing
    - require:
      - file: /testing
      - pkg: git
      - pkg: patch
      {%- if grains['os_family'] not in ('FreeBSD',) %}
      - pkg: subversion
      {%- endif %}
      {%- if grains['os'] == 'openSUSE' %}
      {#- Yes! openSuse ships xml as separate package #}
      - pkg: python-xml
      {%- endif %}
      - pip: SaltTesting
      - pip: virtualenv
      {%- if grains.get('pythonversion')[:2] < [2, 7] %}
      - pip: unittest2
      {%- endif %}
      - pip: mock
      - pip: timelib
      - pip: coverage
      - pip: unittest-xml-reporting
