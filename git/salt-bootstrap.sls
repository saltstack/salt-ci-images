{% set git_url =  pillar.get('git_url', 'https://github.com/saltstack/salt-bootstrap.git') %}

include:
  - git
  - python.salttesting
  - python.virtualenv
  - python.supervisord
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

https://github.com/saltstack/salt-bootstrap.git:
  git.latest:
    - name: https://github.com/saltstack/salt-bootstrap.git
    - rev: 2014.1
    - target: /salt-source
    - require:
      - file: /salt-source
      - pip: virtualenv


copy-salt-config:
  cmd.run:
    - name: cp -Rp /etc/salt /salt-source/system-installation/etc

/salt-source/system-installation:
  file.directory

/salt-source/system-installation/log:
  file.directory

{#
/salt-source/system-installation/etc:
  file.directory
#}

/salt-source/system-installation/var/cache:
  file.directory:
    - makedirs: true

/salt-source/system-installation/var/run/salt:
  file.directory:
    - makedirs: true

/salt-source/system-installation/srv/salt:
  file.directory:
    - makedirs: true

/salt-source/system-installation/srv/pillar:
  file.directory:
    - makedirs: true

adapt-root_dir:
  file.replace:
    - path: /salt-source/system-installation/etc/minion
    - pattern: 'root_dir: /'
    - repl: 'root_dir: /salt-source/system-installation/'

adapt-/var/run:
  file.replace:
    - path: /salt-source/system-installation/etc/minion
    - pattern: /var/run
    - repl: /salt-source/system-installation/var/run

adapt-/var/cache:
  file.replace:
    - path: /salt-source/system-installation/etc/minion
    - pattern: /var/cache/salt
    - repl: /salt-source/system-installation/var/cache

adapt_conf_file:
  file.replace:
    - path: /salt-source/system-installation/etc/minion
    - pattern: 'conf_file: /etc/salt/minion'
    - repl: 'conf_file: /salt-source/system-installation/etc/minion'

adapt-/srv/salt:
  file.replace:
    - path: /salt-source/system-installation/etc/minion
    - pattern: /srv/salt
    - repl: /salt-source/system-installation/srv/salt

adapt-/srv/pillar:
  file.replace:
    - path: /salt-source/system-installation/etc/minion
    - pattern: /srv/salt
    - repl: /salt-source/system-installation/srv/pillar

adapt-/var/log:
  file.replace:
    - path: /salt-source/system-installation/etc/minion
    - pattern: /var/log/salt
    - repl: /salt-source/system-installation/log


install-salt:
  cmd.run:
    - name: {{ python }} setup.py install --salt-root-dir=/salt-source/system-installation/ \
      --salt-config-dir=/salt-source/system-installation/etc \
      --salt-cache-dir=/salt-source/system-installation/cache \
      --salt-sock-dir=/salt-source/system-installation/run/salt \
      --salt-srv-root-dir=/salt-source/system-installation/srv \
      --salt-base-file-roots-dir=/salt-source/system-installation/salt \
      --salt-base-pillar-roots-dir=/salt-source/system-installation/pillar \
      --salt-logs-dir=/salt-source/system-installation/log \
      --salt-pidfile-dir=/salt-source/system-installation/run


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
