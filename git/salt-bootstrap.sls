{%- set test_git_url =  pillar.get('test_git_url', 'https://github.com/saltstack/salt-bootstrap.git') %}
{%- set test_transport = pillar.get('test_transport', 'zeromq') %}

include:
  - git
  - python.salttesting
  {%- if grains.get('pythonversion')[:2] < [2, 7] %}
  - python.unittest2
  - python.argparse
  {%- endif %}
  {%- if grains['os'] == 'openSUSE' %}
  {#- Yes! openSuse ships xml as separate package #}
  - python.xml
  {%- endif %}
  - python.mock
  - python.unittest-xml-reporting

/testing:
  file.directory

{{ test_git_url }}:
  git.latest:
    - name: {{ test_git_url }}
    - rev: {{ pillar.get('test_git_commit', 'develop') }}
    - target: /testing
    - require:
      - file: /testing
      - pkg: git
      {%- if grains['os'] == 'openSUSE' %}
      {#- Yes! openSuse ships xml as separate package #}
      - pkg: python-xml
      {%- endif %}
      - pip: SaltTesting
      {%- if grains.get('pythonversion')[:2] < [2, 7] %}
      - pip: unittest2
      - pip: argparse
      {%- endif %}
      - pip: mock
      - pip: unittest-xml-reporting

{%- if test_git_url != "https://github.com/saltstack/salt-boostrap.git" %}
{#- Add Salt Upstream Git Repo #}
add-upstream-repo:
  cmd.run:
    - name: git remote add upstream https://github.com/saltstack/salt-bootstrap.git
    - cwd: /testing
    - require:
      - git: {{ test_git_url }}

{#- Fetch Upstream Tags -#}
fetch-upstream-tags:
  cmd.run:
    - name: git fetch upstream --tags
    - cwd: /testing
    - require:
      - cmd: add-upstream-repo
{%- endif %}
