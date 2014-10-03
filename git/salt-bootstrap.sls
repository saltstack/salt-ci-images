{% set test_git_url =  pillar.get('test_git_url', 'https://github.com/saltstack/salt-bootstrap.git') %}
{% set test_transport = pillar.get('test_transport', 'zeromq') %}

include:
  - git
  - patch
  {#-
  {%- if grains['os_family'] not in ('FreeBSD',) %}
  - subversion
  {%- endif %}
  #}
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
  - python.libcloud
  - python.requests
  {%- if test_transport == 'raet' %}
  - python.libnacl
  - python.ioflo
  - python.raet
  {%- endif %}
  {%- if grains['os'] == 'openSUSE' %}
  - python-zypp
  {%- endif %}

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
      - pkg: patch
      {#-
      {%- if grains['os_family'] not in ('FreeBSD',) %}
      - pkg: subversion
      {%- endif %}
      #}
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
      - pip: requests
      {%- if test_transport == 'raet' %}
      - pip: libnacl
      - pip: ioflo
      - pip: raet
      {%- endif %}
      {%- if grains['os'] == 'openSUSE' %}
      - cmd: python-zypp
      {%- endif %}

{% if test_git_url != "https://github.com/saltstack/salt-boostrap.git" %}
{#- Add Salt Upstream Git Repo #}
add-upstream-repo:
  cmd.run:
    - name: git remote add upstream https://github.com/saltstack/salt-bootstrap.git
    - cwd: /testing
    - require:
      - git: {{ test_git_url }}

{# Fetch Upstream Tags -#}
fetch-upstream-tags:
  cmd.run:
    - name: git fetch upstream --tags
    - cwd: /testing
    - require:
      - cmd: add-upstream-repo
{% endif %}
