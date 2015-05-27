{% set test_git_url =  pillar.get('test_git_url', 'https://github.com/saltstack/salt.git') %}
{% set test_transport = pillar.get('test_transport', 'zeromq') %}

include:
  - git
  - patch
  - sed
  {#-
  {%- if grains['os_family'] not in ('FreeBSD',) %}
  - subversion
  {%- endif %}
  #}
  - python.salttesting
  - python.virtualenv
  {%- if grains.get('pythonversion')[:2] < [2, 7] %}
  - python.unittest2
  - python.argparse
  {%- endif %}
  {%- if grains['os'] == 'openSUSE' %}
  {#- Yes! openSuse ships xml as separate package #}
  - python.xml
  - python.hgtools
  {%- endif %}
  - python.mock
  - python.timelib
  - python.coverage
  - python.unittest-xml-reporting
  - python.libcloud
  - python.requests
  - python.keyring
  - python.gnupg
  - python.cherrypy
  - python.gitpython
  - python.supervisor
  - python.boto
  - python.moto
  - python.psutil
  - python.tornado
  - python.pycrypto
  - python.pyinotify
  - pyopenssl
  {%- if grains.get('pythonversion')[:2] < [3, 2] %}
  - python.futures
  {%- endif %}
  - dnsutils
  {%- if test_transport == 'raet' %}
  - python.libnacl
  - python.ioflo
  - python.raet
  {%- endif %}
  {%- if grains['os'] == 'Arch' or (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('14.')) %}
  - lxc
  {%- endif %}
  {%- if grains['os'] == 'openSUSE' %}
  - python-zypp
  {%- endif %}
  - python.mysqldb
  - python.dns
  {%- if (grains['os'] not in ['Debian', 'Ubuntu', 'openSUSE'] and not grains['osrelease'].startswith('5.')) or (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('14.')) %}
  - npm
  - bower
  {%- endif %}
  {%- if grains['os'] == 'CentOS' and (grains['osmajorrelease'] == '6' or grains['osmajorrelease'] == '5') %}
  - centos_pycrypto
  {%- endif %}

/testing:
  file.directory

clone-salt-repo:
  git.latest:
    - name: {{ test_git_url }}
    - always_fetch: True
    - force_checkout: True
    - rev: {{ pillar.get('test_git_commit', 'develop') }}
    - target: /testing
    - require:
      - file: /testing
      - pkg: git
      - pkg: patch
      - pkg: sed
      {#-
      {%- if grains['os_family'] not in ('FreeBSD',) %}
      - pkg: subversion
      {%- endif %}
      #}
      {%- if grains['os'] == 'openSUSE' %}
      {#- Yes! openSuse ships xml as separate package #}
      - pkg: python-xml
      - pip: hgtools
      {%- endif %}
      - pip: SaltTesting
      - pip: virtualenv
      {%- if grains.get('pythonversion')[:2] < [2, 7] %}
      - pip: unittest2
      - pip: argparse
      {%- endif %}
      - pip: mock
      - pip: timelib
      - pip: coverage
      - pip: unittest-xml-reporting
      - pip: apache-libcloud
      - pip: requests
      - pip: keyring
      - pip: gnupg
      - pip: cherrypy
      - pip: supervisor
      - pip: boto
      - pip: moto
      - pip: psutil
      - pip: tornado
      - pip: pycrypto
      - pip: pyinotify
      - pkg: pyopenssl
      {%- if grains.get('pythonversion')[:2] < [3, 2] %}
      - pip: futures
      {%- endif %}
      - pip: gitpython
      - pkg: dnsutils
      - pkg: mysqldb
      {%- if test_transport == 'raet' %}
      - pip: libnacl
      - pip: ioflo
      - pip: raet
      {%- endif %}
      {%- if grains['os'] == 'Arch' or (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('14.')) %}
      - pkg: lxc
      {%- endif %}
      {%- if grains['os'] == 'openSUSE' %}
      - cmd: python-zypp
      {%- endif %}
      - pip: dnspython
      {%- if (grains['os'] not in ['Debian', 'Ubuntu', 'openSUSE'] and not grains['osrelease'].startswith('5.')) or (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('14.')) %}
      - pkg: npm
      - npm: bower
      {%- endif %}
      {%- if grains['os'] == 'CentOS' and (grains['osmajorrelease'] == '6' or grains['osmajorrelease'] == '5') %}
      - pkg: uninstall_system_pycrypto
      {%- endif %}

{% if test_git_url != "https://github.com/saltstack/salt.git" %}
{#- Add Salt Upstream Git Repo #}
add-upstream-repo:
  cmd.run:
    - name: git remote add upstream https://github.com/saltstack/salt.git
    - cwd: /testing
    - require:
      - git: clone-salt-repo

{# Fetch Upstream Tags -#}
fetch-upstream-tags:
  cmd.run:
    - name: git fetch upstream --tags
    - cwd: /testing
    - require:
      - cmd: add-upstream-repo
{% endif %}
