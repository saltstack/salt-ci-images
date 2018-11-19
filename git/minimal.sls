force-sync-all:
  module.run:
    - name: saltutil.sync_all
    - order: 1

{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}
{% set on_docker = salt['grains.get']('virtual_subtype', '') in ('Docker',) %}

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

include:
  {%- if grains.get('kernel') == 'Linux' %}
  - man
  - ulimits
  {%- endif %}
  {%- if grains['os'] == 'MacOS' %}
  - python.path
  {% endif %}
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
  # - no_show_proc
  - locale
  - gem
  - python.pip
  - gcc
  - python.headers
  {%- endif %}
  {# On OSX these utils are available from the system rather than the pkg manager (brew) #}
  {%- if grains['os'] not in ('MacOS',) %}
  - git
  - patch
  - sed
  {%- endif %}
  {%- if grains['os'] not in ('MacOS', 'Windows') %}
  - dnsutils
  - extra-swap
  {%- endif %}
  {%- if os_family == 'Suse' %}
  {#- Yes! openSuse ships xml as separate package #}
  - python.xml
  - python.hgtools
  - python.setuptools-scm
  - python-zypp
  - python.certifi
  - susepkgs
  {%- endif %}
  {%- if grains['os'] == 'Arch' or (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('16.')) %}
  - lxc
  {%- endif %}
  {%- if (grains['os'] not in ['Debian', 'Ubuntu', 'SUSE', 'openSUSE', 'Windows'] and not grains['osrelease'].startswith('5.')) or (grains['os'] == 'Ubuntu' and grains['osrelease'].startswith('14.')) %}
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
  {%- if grains['os'] == 'Debian' and grains['osrelease'].startswith('8') %}
  - openssl-dev
  {%- endif %}
  {%- if os_family in ('Arch', 'RedHat', 'Debian') %}
  - nginx
  {%- endif %}
  {%- if os_family == 'Arch' %}
  - lsb_release
  {%- endif %}
  - sssd
  - python.tox
  - cron

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
