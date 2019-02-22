{%- set test_git_url =  pillar.get('test_git_url', 'https://github.com/saltstack/salt.git') %}
{%- set os_family = grains.get('os_family', '')  %}
{%- set on_redhat = True if os_family == 'RedHat' else False %}

include:
  - git
  - patch
  - python.salttesting
  {%- if grains.get('pythonversion')[:2] < [2, 7] %}
  - python.unittest2
  {%- endif %}
  - python.mock
  - python.coverage
  - python.unittest-xml-reporting
  - python.libcloud
  - python.shade
  - python.rackspaceauth
  - python.requests
  - python.keyring
  - python.tornado
  {%- if not pillar.get('py3', False) %}
  - python.futures
  {%- endif %}
  - cloud-only.azure
  - cloud-only.netaddr
  - cloud-only.profitbricks
  - cloud-only.sshpass
  - cloud-only.winexe
  - python.impacket
  - python.winrm
  - python.pypsexec

/testing:
  file.directory

{%- if pillar.get('clone_repo', True) %}
{{ test_git_url }}:
  git.latest:
    - name: {{ test_git_url }}
    - rev: {{ pillar.get('test_git_commit', 'develop') }}
    - target: /testing
    - require:
      - file: /testing
      - pkg: git
      - pkg: patch
      - pip: SaltTesting
      {%- if grains.get('pythonversion')[:2] < [2, 7] %}
      - pip: unittest2
      {%- endif %}
      - pip: mock
      - pip: coverage
      - pip: unittest-xml-reporting
      - pip: apache-libcloud
      - pip: requests
      - pip: keyring
      - pip: azure
      - pip: tornado
      {%- if not pillar.get('py3', False) %}
      - pip: futures
      {%- endif %}
      - pkg: sshpass

{%- if test_git_url != "https://github.com/saltstack/salt.git" %}
{#- Add Salt Upstream Git Repo #}
add-upstream-repo:
  cmd.run:
    - name: git remote add upstream https://github.com/saltstack/salt.git
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
{%- endif %}
