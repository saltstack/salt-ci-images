{%- set default_test_git_url = 'https://github.com/saltstack/salt.git' %}
{%- set test_git_url = pillar.get('test_git_url', default_test_git_url) %}
{%- set test_transport = pillar.get('test_transport', 'zeromq') %}
{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}
{% set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}

{%- if os_family == 'RedHat' and os_major_release == 5 %}
  {%- set on_redhat_5 = True %}
{%- else %}
  {%- set on_redhat_5 = False %}
{%- endif %}

{%- if pillar.get('testing_dir') %}
  {%- set testing_dir = pillar.get('testing_dir') %}
{%- elif grains['os'] == 'Windows' %}
  {%- set testing_dir = 'C:\\testing' %}
{%- else %}
  {%- set testing_dir = '/testing' %}
{%- endif %}

{%- if os_family == 'Arch' %}
  {%- set on_arch = True %}
{%- else %}
  {%- set on_arch = False %}
{%- endif %}

{%- if pillar.get('py3', False) %}
  {%- set python = 'python3' %}
{%- else %}
  {%- if on_arch %}
    {%- set python = 'python2' %}
  {%- elif on_redhat_5 %}
    {%- set python = 'python26' %}
  {%- else %}
    {%- set python = 'python' %}
  {%- endif %}
{%- endif %}

{# handling requirements #}
{% if test_transport == 'zeromq' %}
  {% set transport_reqs = ['pycrypto>=2.6.1', 'pyzmq>=2.2.0'] %}
{% elif test_transport == 'raet' %}
  {% set transport_reqs = ['libnacl>=1.0.0', 'ioflo>=1.1.7', 'raet>=0.6.0'] %}
{% endif %}

{% set dev_reqs = ['mock', 'apache-libcloud>=0.14.0', 'boto>=2.32.1', 'boto3>=1.2.1', 'moto>=0.3.6', 'SaltTesting>=2016.10.26', 'SaltPyLint'] %}
{% set base_reqs = ['Jinja2', 'msgpack-python>0.3', 'PyYAML', 'MarkupSafe', 'requests>=1.0.0', 'tornado>=4.2.1'] %}

include:
  # All VMs get docker-py so they can run unit tests
  - python.docker
  {%- if grains['os'] == 'CentOS' and os_major_release == 7 %}
  # Docker integration tests only on CentOS 7 (for now)
  - docker
  {%- endif %}
  {%- if grains['os'] == 'Ubuntu' and os_major_release >= 17 %}
  - dpkg
  {%- endif %}
  {%- if grains['os'] not in ('Windows',) %}
  - locale
  {%- endif %}
  {# on OSX, these utils are available from the system rather than the pkg manager (brew) #}
  {%- if grains.get('os', '') != 'MacOS' %}
  {%- if grains.get('os', '') != 'Windows' %}
  - git
  {%- endif %}
  - patch
  - sed
  {%- endif %}
  {#-
  {%- if os_family not in ('FreeBSD',) %}
  - subversion
  {%- endif %}
  #}
  {# if (grains['os'] in ('RedHat', 'CentOS') and grains['osrelease'].startswith('7')) or (grains['os'] in ('Ubuntu') and grains['osrelease'] in ('16.04', '14.04')) #}
  #- openstack
  {# endif #}
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
  {%- if os_family == 'Suse' %}
  - python.certifi
  {%- endif %}
  - python.mock
  - python.six
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
  {%- if not ( pillar.get('py3', False) and grains['os'] == 'Windows' ) %}
  - python.supervisor
  {%- endif %}
  - python.boto
  - python.moto
  - python.kubernetes
  - python.psutil
  - python.tornado
  - python.pyvmomi
  - python.pycrypto
  - python.setproctitle
  {%- if grains['os'] not in ('MacOS', 'Windows') %}
  - python.pyinotify
  {%- endif %}
  - python.msgpack
  - python.jsonschema
  - python.rfc3987
  - python.strict_rfc3339
  {%- if (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('12.')) or (grains['os'] == 'CentOS' and os_major_release == 5) %}
  - python.jinja2
  {%- endif %}
  - pyopenssl
  {%- if grains['os'] != 'Windows' %}
  - gem
  {%- endif %}
  {%- if not pillar.get('py3', False) %}
  - python.futures
  {%- endif %}
  {%- if grains['os'] not in ('MacOS', 'Windows') %}
  - dnsutils
  {%- endif %}
  - python.ioflo
  {%- if test_transport == 'raet' %}
  - python.libnacl
  - python.raet
  {%- endif %}
  {%- if grains['os'] == 'Arch' or (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('16.')) %}
  - lxc
  {%- endif %}
  {%- if grains['os'] == 'openSUSE' %}
  - python-zypp
  {%- endif %}
  {%- if grains['os'] not in ('MacOS', 'Windows') %}
  - python.mysqldb
  {%- endif %}
  - python.dns
  {%- if (grains['os'] not in ['Debian', 'Ubuntu', 'openSUSE', 'Windows'] and not grains['osrelease'].startswith('5.')) or (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('14.')) %}
  - npm
  - bower
  {%- endif %}
  {%- if grains['os'] == 'Fedora' or (grains['os'] == 'CentOS' and os_major_release == 5) %}
  - gpg
  {%- endif %}
  {%- if grains['os'] == 'Fedora' %}
  - versionlock
  - redhat-rpm-config
  {%- endif %}
  {%- if grains['os'] != 'MacOS' %}
  {%- if grains['os'] != 'Windows' %}
  - extra-swap
  {%- endif %}
  {%- if grains['os'] != 'Windows' or (not (pillar.get('py3', False) and grains['os'] == 'Windows' )) %}
  - dmidecode
  {%- endif %}
  {%- endif %}
  {%- if grains['os'] in ('MacOS', 'Debian') %}
  - openssl
  {%- endif %}
  {%- if grains['os'] == 'Debian' and grains['osrelease'].startswith('8') %}
  - openssl-dev
  {%- endif %}
  - python.salttesting
  {%- if grains['os'] != 'Ubuntu' or (grains['os'] == 'Ubuntu' and not grains['osrelease'].startswith('12.')) %}
  - python.pytest
  - python.pytest-tempdir
  - python.pytest-catchlog
  - python.pytest-helpers-namespace
  - python.pytest-salt
  {%- endif %}
  {%- if grains['os'] in ['CentOS', 'Debian', 'Fedora', 'FreeBSD', 'MacOS' , 'Ubuntu'] %}
  - python.junos-eznc
  - python.jxmlease
  {%- endif %}
  {%- if os_family in ('Arch', 'RedHat', 'Debian') %}
  - nginx
  {%- endif %}
  {%- if grains['os'] == 'MacOS' %}
  - python.pyyaml
  {%- endif %}
  {%- if os_family == 'Arch' %}
  - lsb_release
  {%- endif %}
  - sssd

{{ testing_dir }}:
  file.directory

{%- if pillar.get('clone_repo', True) %}
clone-salt-repo:
  git.latest:
    - name: {{ test_git_url }}
    - force_checkout: True
    - force_reset: True
    - rev: {{ pillar.get('test_git_commit', 'develop') }}
    - target: {{ testing_dir }}
    - require:
      # All VMs get docker-py so they can run unit tests
      - pip: docker
      # Docker integration tests only on CentOS 7 (for now)
      {%- if grains['os'] == 'CentOS' and os_major_release == 7 %}
      {%- if on_docker == False %}
      - service: docker
      - pkg: docker
      {%- endif %}
      - file: /usr/bin/busybox
      {%- endif %}
      - file: {{ testing_dir }}
      {%- if grains['os'] not in ('MacOS',) %}
      {%- if grains['os'] == 'FreeBSD' %}
      - cmd: add-extra-swap
      {%- else %}
      {%- if grains['oscodename'] != 'openSUSE Leap 42.2' %}
      {%- if grains['os'] != 'Windows' and on_docker == False %}
      - mount: add-extra-swap
      {%- endif %}
      {%- endif %}
      {%- endif %}
      {%- if grains['os'] == 'Windows' %}
      - pip: patch
      - pip: sed
      {%- else %}
      - pkg: git
      - pkg: patch
      - pkg: sed
      {%- endif %}
      {%- endif %}
      {#-
      {%- if os_family not in ('FreeBSD',) %}
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
      {%- if os_family == 'Suse' %}
      - pip: certifi
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
      {% if not ( pillar.get('py3', False) and grains['os'] == 'Windows' ) %}
      - pip2: supervisor
      {% endif %}
      - pip: boto
      - pip: moto
      - pip: kubernetes
      - pip: psutil
      - pip: tornado
      - pip: pyvmomi
      - pip: pycrypto
      - pip: pyopenssl
      {%- if (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('12.')) or (grains['os'] == 'CentOS' and os_major_release == 5) %}
      - pip: jinja2
      {%- endif %}
      {%- if grains['os'] != 'MacOS' %}
      - pip: pyinotify
      {%- endif %}
      {%- if not pillar.get('py3', False) %}
      - pip: futures
      {%- endif %}
      - pip: gitpython
      {%- if grains['os'] not in ('MacOS', 'Windows') %}
      - pkg: dnsutils
      - pkg: mysqldb
      {%- endif %}
      - pip: ioflo
      {%- if test_transport == 'raet' %}
      - pip: libnacl
      - pip: raet
      {%- endif %}
      {%- if grains['os'] == 'Arch' or (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('16.')) %}
      - pkg: lxc
      {%- endif %}
      {%- if grains['os'] == 'openSUSE' %}
      - cmd: python-zypp
      {%- endif %}
      - pip: dnspython
      {%- if (grains['os'] not in ['Debian', 'Ubuntu', 'openSUSE'] and not grains['osrelease'].startswith('5.')) or (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('14.')) %}
      {%- if grains['os'] != 'Windows' %}
      - pkg: npm
      - npm: bower
      {%- endif %}
      {%- endif %}
      {%- if grains['os'] == 'Fedora' or (grains['os'] == 'CentOS' and os_major_release == 5) %}
      - pkg: gpg
      {%- endif %}
      {%- if grains['os'] != 'MacOS' %}
      {%- if grains['os'] == 'Windows' %}
      {%- if not pillar.get('py3', False) %}
      - pip: dmidecode
      {%- endif %}
      {%- else %}
      - pkg: dmidecode
      {%- endif %}
      {%- endif %}
      {%- if grains['os'] == 'Fedora' %}
      - pkg: redhat-rpm-config
      {%- endif %}
      {%- if grains['os'] in ('MacOS', 'Debian') %}
      - pkg: openssl
      {%- endif %}
      {%- if grains['os'] == 'Debian' and grains['osrelease'].startswith('8') %}
      - pkg: openssl-dev-libs
      {%- endif %}
      {%- if os_family in ('Arch', 'RedHat', 'Debian') %}
      - pkg: nginx
      {%- endif %}
      {%- if os_family == 'Arch' %}
      - pkg: lsb-release
      {%- endif %}
      # disable sssd if running
      - service: sssd

{%- if test_git_url != default_test_git_url %}
{#- Add Salt Upstream Git Repo #}
add-upstream-repo:
  cmd.run:
    - name: git remote add upstream {{ default_test_git_url }}
    - cwd: {{ testing_dir }}
    - require:
      - git: clone-salt-repo
    - unless: 'cd {{ testing_dir }} ; git remote -v | grep {{ default_test_git_url }}'

{# Fetch Upstream Tags -#}
fetch-upstream-tags:
  cmd.run:
    - name: git fetch upstream --tags
    - cwd: {{ testing_dir }}
    - require:
      - cmd: add-upstream-repo
{%- endif %}
{%- endif %}

{%- if pillar.get('py3', False) %}
{#- Install Salt Dev Dependencies #}
{%- if test_transport in ('zeromq', 'raet') -%}
  {% for req in transport_reqs %}
install-transport-{{ req }}:
  pip.installed:
    - name: {{ req }}
  {% endfor %}
{%- endif -%}

{% for req in dev_reqs %}
install-dev-{{ req }}:
  pip.installed:
    - name: {{ req }}
{% endfor %}

{% for req in base_reqs %}
install-base-{{ req }}:
  pip.installed:
    - name: {{ req }}
{% endfor %}

install-salt-pytest-pip-deps:
  pip.installed:
    - requirements: {{ testing_dir }}/requirements/pytest.txt
    - onlyif: '[ -f {{ testing_dir }}/requirements/pytest.txt ]'
{%- endif %}

{# npm v5 workaround for issue #41770 #}
{%- if grains['os'] == 'MacOS' %}
downgrade_node:
  cmd.run:
    - name: 'brew switch node 7.0.0'
    - runas: jenkins

downgrade_npm:
  npm.installed:
    - name: npm@3.10.8

pin_npm:
  cmd.run:
    - name: 'brew pin node'
    - runas: jenkins
{%- endif %}
