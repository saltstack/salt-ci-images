{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}
{%- set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}

{%- if pillar.get('testing_dir') %}
  {%- set testing_dir = pillar.get('testing_dir') %}
{%- elif os_family == 'Windows' %}
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
  {%- else %}
    {%- set python = 'python' %}
  {%- endif %}
{%- endif %}

include:
  {%- if grains['os_family'] == 'Debian' %}
  - apt
  {%- endif %}
  {%- if grains['os'] == 'Windows' %}
  - windows
  - vim
  {%- endif %}
  {%- if grains.get('kernel') == 'Linux' %}
  - man
  - ulimits
  {%- endif %}
  {%- if grains['os'] == 'MacOS' %}
  - python.path
  {%- endif %}
  - python.more-itertools
  # All VMs get docker-py so they can run unit tests
  {%- if grains['os'] == 'CentOS' and os_major_release == 7 or grains['os'] == 'Ubuntu' and os_major_release == 16 %}
  # Docker integration tests only on CentOS 7 (for now)
  - docker
  - vault
  {%- endif %}
  {%- if grains['os'] == 'Ubuntu' and os_major_release >= 17 %}
  - dpkg
  {%- endif %}
  {%- if grains['os'] not in ('Windows',) %}
  - no_show_proc
  - locale
  - gem
  - python
  - python.pip
  - gcc
  {%- endif %}
  - libsodium
  {#- On OSX these utils are available from the system rather than the pkg manager (brew) #}
  {%- if grains['os'] not in ('MacOS',) %}
  - git
  - patch
  - sed
  {%- endif %}
  {%- if grains['os'] not in ('MacOS', 'Windows') %}
  {%- if grains['os_family'] in ('Arch', 'Debian', 'Suse', 'RedHat') %}
    {%- if grains['os'] != 'CentOS' or (grains['os'] == 'CentOS' and os_major_release > 6) %} {#- Don't install openldap on CentOS 6 #}
  - openldap
    {%- endif %}
  {%- endif %}
  - dnsutils
  - rsync
  - swig  {#- Swig is required to install m2crypto #}
    {%- if pillar.get('extra-swap', True) %}
  - extra-swap
    {%- endif %}
  {%- endif %}
  {%- if os_family == 'Suse' %}
  {#- Yes! openSuse ships xml as separate package #}
  - python.xml
  - python.hgtools
  - python.setuptools-scm
  {%- if not grains['osrelease'].startswith('15') %}
  - python-zypp
  {%- endif %}
  - python.certifi
  - susepkgs
  {%- endif %}
  {%- if grains['os'] == 'Arch' or (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('16.')) %}
  - lxc
  {%- endif %}
  {%- if (grains['os'] not in ['Amazon', 'Debian', 'Ubuntu', 'SUSE', 'openSUSE', 'Windows'] and not grains['osrelease'].startswith('5.')) or (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('14.')) %}
  - npm
  - bower
  {%- endif %}
  {%- if grains['os'] == 'Fedora' %}
  - gpg
  - versionlock
  - redhat-rpm-config
  {%- endif %}
  {%- if grains['os'] != 'Windows' or (not (pillar.get('py3', False) and grains['os'] == 'Windows' )) %}
  - dmidecode
  {%- endif %}
  {%- if grains['os'] in ('MacOS', 'Debian') %}
  - openssl
  {%- endif %}
  {%- if grains['os'] != 'Windows' %}
    {%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
    {#- These distributions don't ship the develop headers separately #}
  - openssl-dev
    {%- endif %}
  {%- endif %}
  {%- if grains['os'] not in ('Amazon',) and os_family in ('Arch', 'RedHat', 'Debian') %}
  - nginx
  {%- endif %}
  {%- if os_family == 'Arch' %}
  - lsb_release
  {%- endif %}
  {%- if not on_docker %}
  - sssd
  {%- endif %}
  - python.tox
  - python.nox
  - cron
  {%- if 'Linux' in grains.kernel %}
  - timesync
  - metricbeat
  - filebeat
  - heartbeat
    {%- if 'RedHat' in grains.os_family %}
      {%- if grains.osfinger is defined and grains.osfinger not in ['CentOS-6', 'Amazon Linux AMI-2018'] %}
  - journalbeat
      {%- endif %}
    {%- else %}
  - journalbeat
    {%- endif %}
  {%- endif %}
{%- if os_family not in ('Windows', 'MacOS',)  %}
  - sshd_config
{%- endif %}

minion-service-stopped:
  service.dead:
    - name: salt-minion
    - enable: False

{%- if pillar.get('create_testing_dir', True) %}
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
{%- endif %}

{#- npm v5 workaround for issue #41770 #}
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

{#- Make sure there's at least one state entry in the state file #}
noop-{{ sls }}:
  test.succeed_without_changes
