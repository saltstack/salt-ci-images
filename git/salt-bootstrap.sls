{% from '_python.sls' import python with context %}
{% set git_url =  pillar.get('git_url', 'https://github.com/saltstack/salt-bootstrap.git') %}
{% set sssi = '/salt-source/system-installation' %}

include:
  - git
  - python.salttesting
  - python.virtualenv
  - python.supervisor
  {%- if grains.get('pythonversion')[:2] < [2, 7] %}
  - python.unittest2
  {%- endif %}
  {%- if grains['os'] == 'openSUSE' %}
  {#- Yes! openSuse ships xml as separate package #}
  - python.xml
  {%- endif %}
  - python.mock
  - python.unittest-xml-reporting


{# Checkout Salt which should be the long running minion, available while the bootstrap
   script installs and uninstalls Salt over and over again #}
/salt-source:
  file.directory

https://github.com/saltstack/salt.git:
  git.latest:
    - name: https://github.com/saltstack/salt.git
    - rev: 2014.1
    - target: /salt-source
    - require:
      - file: /salt-source
      - pip: virtualenv


copy-salt-config:
  cmd.run:
    - name: cp -Rp /etc/salt {{ sssi }}/etc

{{ sssi }}:
  file.directory

{{ sssi }}/log:
  file.directory

{#
{{ sssi }}/etc:
  file.directory
#}

{{ sssi }}/var/cache:
  file.directory:
    - makedirs: true

{{ sssi }}/var/run/salt:
  file.directory:
    - makedirs: true

{{ sssi }}/srv/salt:
  file.directory:
    - makedirs: true

{{ sssi }}/srv/pillar:
  file.directory:
    - makedirs: true

adapt-root_dir:
  file.replace:
    - name: {{ sssi }}/etc/minion
    - pattern: 'root_dir: /'
    - repl: 'root_dir: {{ sssi }}/'

adapt-/var/run:
  file.replace:
    - name: {{ sssi }}/etc/minion
    - pattern: /var/run
    - repl: {{ sssi }}/var/run

adapt-/var/cache:
  file.replace:
    - name: {{ sssi }}/etc/minion
    - pattern: /var/cache/salt
    - repl: {{ sssi }}/var/cache

adapt_conf_file:
  file.replace:
    - name: {{ sssi }}/etc/minion
    - pattern: 'conf_file: /etc/salt/minion'
    - repl: 'conf_file: {{ sssi }}/etc/minion'

adapt-/srv/salt:
  file.replace:
    - name: {{ sssi }}/etc/minion
    - pattern: /srv/salt
    - repl: {{ sssi }}/srv/salt

adapt-/srv/pillar:
  file.replace:
    - name: {{ sssi }}/etc/minion
    - pattern: /srv/salt
    - repl: {{ sssi }}/srv/pillar

adapt-/var/log:
  file.replace:
    - name: {{ sssi }}/etc/minion
    - pattern: /var/log/salt
    - repl: {{ sssi }}/log


install-salt:
  cmd.run:
    - name: {{ python }} setup.py install --salt-root-dir={{ sssi }}/ --salt-config-dir={{ sssi }}/etc --salt-cache-dir={{ sssi }}/cache --salt-sock-dir={{ sssi }}/run/salt --salt-srv-root-dir={{ sssi }}/srv --salt-base-file-roots-dir={{ sssi }}/salt --salt-base-pillar-roots-dir={{ sssi }}/pillar --salt-logs-dir={{ sssi }}/log --salt-pidfile-dir={{ sssi }}/run
    - cwd: /salt-source


run-salt:
  supervisord:
    - running
    - name: salt
    - require:
      - pip: supervisor


{# Setup Salt Bootstrap Source #}
/testing:
  file.directory

{{git_url}}:
  git.latest:
    - name: {{ git_url }}
    - rev: {{ pillar.get('git_commit', 'develop') }}
    - target: /testing
    - require:
      - file: /testing
      - pkg: git
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
      - pip: unittest-xml-reporting

{% if git_url != "https://github.com/saltstack/salt-bootstrap.git" %}
{#- Add Salt Upstream Git Repo #}
add-upstream-repo:
  cmd.run:
    - name: git remote add upstream https://github.com/saltstack/salt-bootstrap.git
    - cwd: /testing
    - require:
      - git: {{ git_url }}

{# Fetch Upstream Tags -#}
fetch-upstream-tags:
  cmd.run:
    - name: git fetch upstream --tags
    - cwd: /testing
    - require:
      - cmd: add-upstream-repo
{% endif %}
