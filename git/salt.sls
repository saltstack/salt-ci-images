force-sync-all:
  module.run:
    - name: saltutil.sync_all
    - order: 1

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
{%- elif os_family == 'Windows' %}
  {%- set testing_dir = 'C:\\testing' %}
{%- else %}
  {%- set testing_dir = '/testing' %}
{%- endif %}

{%- if os_family == 'Windows' %}
stop-minion:
  service.dead:
    - name: salt-minion
    - enable: False
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

{% set dev_reqs = ['mock', 'apache-libcloud>=0.14.0', 'boto>=2.32.1', 'boto3>=1.2.1', 'moto>=0.3.6', 'SaltTesting>=2016.10.26', 'SaltPyLint'] %}
{% set base_reqs = ['Jinja2', 'msgpack-python>0.3', 'PyYAML', 'MarkupSafe', 'requests>=1.0.0', 'tornado%s'|format(salt.pillar.get('tornado:version', '<5.0.0'))] %}

include:
  {%- if grains.get('kernel') == 'Linux' %}
  - man
  - python.ansible
  {%- endif %}
  {%- if grains['os'] == 'MacOS' %}
  - python.path
  {% endif %}
  # All VMs get docker-py so they can run unit tests
  - python.docker
  - python.pylxd
  {%- if grains['os'] == 'CentOS' and os_major_release == 7 or grains['os'] == 'Ubuntu' and os_major_release == 16 %}
  - docker
  - vault
  {%- endif %}
  {%- if grains['os'] == 'CentOS' and os_major_release == 7 %}
  - python.zookeeper
  {%- endif %}
  {%- if grains['os'] == 'Ubuntu' and os_major_release >= 17 %}
  - dpkg
  {%- endif %}
  {%- if grains['os'] not in ('Windows',) %}
  - locale
  {%- endif %}
  {# On Windows (Jenkins builds) this is already installed but we may need this on other windows builds. #}
  {%- if grains['os'] not in ('MacOS',) %}
  - git
  {%- endif %}
  {# On OSX these utils are available from the system rather than the pkg manager (brew) #}
  {%- if grains['os'] != 'MacOS' %}
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
  - python.setuptools
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
  - python.etcd
  - python.gitpython
  - python.pygit2
  {%- if not ( pillar.get('py3', False) and grains['os'] == 'Windows' ) %}
  - python.supervisor
  {%- if test_transport in ('zeromq') %}
  - python.pyzmq
  - python.pycrypto
  {%- endif %}
  {%- endif %}
  - python.boto
  - python.moto
  - python.kubernetes
  - python.psutil
  - python.tornado
  - python.pyvmomi
  - python.pycrypto
  - python.setproctitle
  {%- if grains['os'] not in ('Windows',) %}
  - python.clustershell
  {%- endif %}
  {%- if grains['os'] not in ('MacOS', 'Windows') %}
  - python.ldap
  - python.cherrypy
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
  - python.croniter
  - cron
  {%- if (grains['os'] not in ['Debian', 'Ubuntu', 'openSUSE', 'Windows'] and not grains['osrelease'].startswith('5.')) or (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('14.')) %}
  - npm
  - bower
  {%- endif %}
  {%- if grains['os'] in ('Fedora', 'MacOS') or (grains['os'] == 'CentOS' and os_major_release == 5) %}
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
  {%- if grains['kernel'] in ('Linux', 'Darwin') %}
  - ulimits
  {%- endif %}

testing-dir:
  file.directory:
    - name: {{ testing_dir }}
  {%- if grains['os'] == 'Windows' %}
    - win_owner: 'Users'
    - win_inheritance: true
    - win_perms:
        Users:
          perms: full_control
  {%- endif %}

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
      - pip: docker_py
      # Docker integration tests only on CentOS 7 (for now)
      {%- if grains['os'] == 'CentOS' and os_major_release == 7 or grains['os'] == 'Ubuntu' and os_major_release == 16 %}
      {%- if on_docker == False %}
      - service: docker
      - pkg: docker
      {%- endif %}
      - file: /usr/bin/busybox
      {%- endif %}
      - file: testing-dir
      {%- if grains['os'] not in ('MacOS',) %}
      {%- if grains['os'] == 'FreeBSD' %}
      - cmd: add-extra-swap
      {%- else %}
      {%- if salt.grains.get('os_family') not in ('Suse', ) %}  
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
      {%- if grains['os'] == 'MacOS' %}
      - cmd: timelib
      {% else %}
      - pip: timelib
      {% endif %}
      - pip: coverage
      - pip: unittest-xml-reporting
      - pip: apache-libcloud
      - pip: requests
      - pip: keyring
      - pip: gnupg
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
      {%- if grains['os'] not in ('Windows',) %}
      - pip: clustershell
      {%- endif %}
      {%- if (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('12.')) or (grains['os'] == 'CentOS' and os_major_release == 5) %}
      - pip: jinja2
      {%- endif %}
      {%- if grains['os'] not in ('MacOS', 'Windows') %}
      - pip: python-ldap
      - pip: cherrypy
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
      {%- if grains['os'] not in ('MacOS', 'Windows') %}
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
      {%- if grains.get('kernel') == 'Linux' %}
      - file: ulimits-nofile
      - pkg: man
      {%- endif %}

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

{% for req in dev_reqs %}
install-dev-{{ req }}:
  pip.installed:
    - name: {{ req }}
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
{% endfor %}

{% for req in base_reqs %}
install-base-{{ req }}:
  pip.installed:
    - name: {{ req }}
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
{% endfor %}

install-salt-pytest-pip-deps:
  pip.installed:
    - requirements: {{ testing_dir }}/requirements/pytest.txt
    - onlyif: '[ -f {{ testing_dir }}/requirements/pytest.txt ]'
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
{%- endif %}

{# npm v5 workaround for issue #41770 #}
{# node version 7.0.0 is not avaliable in MAC OSX 13(High Sierra) #}
{# installing node, npm, and bower manually for the MAC OS. #}
{%- if grains['os'] == 'MacOS' %}
download_node:
  file.managed:
    - source: https://nodejs.org/download/release/v7.0.0/node-v7.0.0.pkg
    - source_hash: sha256=5d935d0e2e864920720623e629e2d4fb0d65238c110db5fbe71f73de8568c024
    - name: /tmp/node-v7.0.0.pkg
    - user: root
    - group: wheel

install_node:
  macpackage.installed:
    - name: /tmp/node-v7.0.0.pkg
    - reload_modules: True

bower:
  npm.installed:
    - force_reinstall: True
    - require:
      - macpackage: install_node

# workaround for https://github.com/saltstack/salt-jenkins/issues/643 #}
update-brew:
  cmd.run:
    - name: brew update
    - runas: jenkins
{%- endif %}
