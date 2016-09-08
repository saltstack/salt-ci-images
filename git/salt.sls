{% set default_test_git_url = 'https://github.com/saltstack/salt.git' %}
{% set test_git_url = pillar.get('test_git_url', default_test_git_url) %}
{% set test_transport = pillar.get('test_transport', 'zeromq') %}
{% set python3 = pillar.get('py3', False) %}

include:
  {# on OSX, these utils are available from the system rather than the pkg manager (brew) #}
  {% if grains.get('os', '') != 'MacOS' %}
  - git
  - patch
  - sed
  {% endif %}
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
  - python.setuptools-scm
  {%- endif %}
  {%- if grains['os'] == 'Arch' %}
  - python.setuptools
  {%- endif %}
  - python.six
  - python.mock
  - python.timelib
  - python.coverage
  - python.unittest-xml-reporting
  - python.libcloud
  - python.requests
  - python.keyring
  - python.gnupg
  - python.cherrypy
  - python.etcd
  - python.gitpython
  - python.supervisor
  - python.boto
  - python.moto
  - python.psutil
  - python.tornado
  - python.pyvmomi
  - python.pycrypto
  - python.setproctitle
  {% if grains['os'] != 'MacOS' %}
  - python.pyinotify
  {% endif %}
  - python.msgpack
  - python.jsonschema
  - python.rfc3987
  - python.strict_rfc3339
  - python.docker
  {%- if (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('12.')) or (grains['os'] == 'CentOS' and grains['osmajorrelease'] == '5') %}
  - python.jinja2
  {%- endif %}
  - pyopenssl
  - gem
  {%- if grains.get('pythonversion')[:2] < [3, 2] %}
  - python.futures
  {%- endif %}
  {% if grains['os'] != 'MacOS' %}
  - dnsutils
  {% endif %}
  - python.ioflo
  {%- if test_transport == 'raet' %}
  - python.libnacl
  - python.raet
  {%- endif %}
  {%- if grains['os'] == 'Arch' or (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('14.')) %}
  - lxc
  {%- endif %}
  {%- if grains['os'] == 'openSUSE' %}
  - python-zypp
  {%- endif %}
  {% if grains['os'] != 'MacOS' %}
  - python.mysqldb
  {% endif %}
  - python.dns
  {%- if (grains['os'] not in ['Debian', 'Ubuntu', 'openSUSE'] and not grains['osrelease'].startswith('5.')) or (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('14.')) %}
  - npm
  - bower
  {%- endif %}
  {%- if grains['os'] == 'CentOS' and grains['osmajorrelease'] == '6' %}
  - centos_pycrypto
  {%- endif %}
  {%- if grains['os'] == 'Fedora' or (grains['os'] == 'CentOS' and grains['osmajorrelease'] == '5') %}
  - gpg
  {%- endif %}
  {%- if grains['os'] == 'Fedora' and grains['osrelease'] == '22' or '23' %}
  - versionlock
  {% endif %}
  {%- if grains['os'] == 'Fedora' and grains['osrelease'] == '22' %}
  - dnf-plugins
  {% endif %}
  {%- if grains['os'] == 'Fedora' and grains['osrelease'] == '23' %}
  - redhat-rpm-config
  {% endif %}
  {% if grains['os'] != 'MacOS' %}
  {% if grains['os'] != 'FreeBSD' %}
  - extra-swap
  {% endif %}
  - dmidecode
  {% endif %}
  {% if grains['os'] == 'MacOS' %}
  - openssl
  {% endif %}
  {% if python3 %}
  - python3-setup
  {% endif %}

/testing:
  file.directory

clone-salt-repo:
  git.latest:
    - name: {{ test_git_url }}
    - always_fetch: True
    - force_checkout: True
    - force_reset: True
    - rev: {{ pillar.get('test_git_commit', 'develop') }}
    - target: /testing
    - require:
      - file: /testing
      {% if grains['os'] not in ['FreeBSD', 'MacOS'] %}
      - mount: add-extra-swap
      - pkg: git
      - pkg: patch
      - pkg: sed
      {% endif %}
      {#-
      {%- if grains['os_family'] not in ('FreeBSD',) %}
      - pkg: subversion
      {%- endif %}
      #}
      {%- if grains['os'] == 'openSUSE' %}
      {#- Yes! openSuse ships xml as separate package #}
      - pkg: python-xml
      - pip: hgtools
      - pip: setuptools-scm
      {%- endif %}
      {%- if grains['os'] == 'Arch' %}
      - pip: setuptools
      - pip: six
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
      - pip: python-etcd
      - pip: supervisor
      - pip: boto
      - pip: moto
      - pip: psutil
      - pip: tornado
      - pip: pyvmomi
      - pip: pycrypto
      {%- if (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('12.')) or (grains['os'] == 'CentOS' and grains['osmajorrelease'] == '5') %}
      - pip: jinja2
      {%- endif %}
      {% if grains['os'] != 'MacOS' %}
      - pip: pyinotify
      - pkg: pyopenssl
      {% endif %}
      {%- if grains.get('pythonversion')[:2] < [3, 2] %}
      - pip: futures
      {%- endif %}
      - pip: gitpython
      {% if grains['os'] != 'MacOS' %}
      - pkg: dnsutils
      - pkg: mysqldb
      {%- endif %}
      - pip: ioflo
      {%- if test_transport == 'raet' %}
      - pip: libnacl
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
      {%- if grains['os'] == 'CentOS' and grains['osmajorrelease'] == '6' %}
      - pkg: uninstall_system_pycrypto
      {%- endif %}
      {%- if grains['os'] == 'Fedora' or (grains['os'] == 'CentOS' and grains['osmajorrelease'] == '5') %}
      - pkg: gpg
      {%- endif %}
      {% if grains['os'] != 'MacOS' %}
      - pkg: dmidecode
      {% endif %}
      {%- if grains['os'] == 'Fedora' and grains['osrelease'] == '23' %}
      - pkg: redhat-rpm-config
      {% endif %}
      {% if grains['os'] == 'MacOS' %}
      - pkg: openssl
      {% endif %}

{% if test_git_url != default_test_git_url %}
{#- Add Salt Upstream Git Repo #}
add-upstream-repo:
  cmd.run:
    - name: git remote add upstream {{ default_test_git_url }}
    - cwd: /testing
    - require:
      - git: clone-salt-repo
    - unless: 'cd /testing ; git remote -v | grep {{ default_test_git_url }}'

{# Fetch Upstream Tags -#}
fetch-upstream-tags:
  cmd.run:
    - name: git fetch upstream --tags
    - cwd: /testing
    - require:
      - cmd: add-upstream-repo
{% endif %}
