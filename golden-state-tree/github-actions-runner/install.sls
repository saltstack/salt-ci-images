{%- if grains['os'] == 'Windows' %}
  {%- set runner_base_directory = "c:" %}
{%- else %}
  {%- set runner_base_directory = "/opt" %}
{%- endif %}

{%- if grains['os'] == 'VMware Photon OS' %}
{#- Photon OS has /opt with perms too closed for another user to access #}
{{ runner_base_directory}}:
  file.directory:
    - user: root
    - group: sudo
    - dir_mode: "0751"
{%- endif %}

{{ runner_base_directory}}/hostedtoolcache:
  file.directory:
  {%- if grains['os'] != 'Windows' %}
    - user: actions-runner
    - group: actions-runner
    - dir_mode: "0755"
  {%- else %}
    - win_owner: Administrator
  {%- endif %}

download-and-decompress-runner-tarball:
  archive.extracted:
    - name: {{ runner_base_directory}}/actions-runner
    - source: {{ pillar["github_actions_runner_tarball_url"] }}
  {%- if grains['os'] != 'Windows' %}
    - user: actions-runner
    - group: actions-runner
  {%- else %}
    - enforce_toplevel: false
  {%- endif %}
    - skip_verify: true
    - keep_source: false

{{ runner_base_directory}}/actions-runner/.env:
  file.append:
    - text:
      - ImageOS={{ grains.get('osfinger', grains['osfullname'].replace(' ', '-')) }}
    - require:
      - download-and-decompress-runner-tarball

install-runner-dependencies:
  {%- if pillar["github_actions_runner_install_dependencies"] %}
  cmd.run:
    - name: {{ runner_base_directory}}/actions-runner/bin/installdependencies.sh
    - require:
      - download-and-decompress-runner-tarball
  {%- else %}
  pkg.installed:
    - pkgs:
    {%- if grains['os'] == 'Windows' %}
      - awscli
    {%- else %}
      - lttng-ust
      - zlib
      {%- if grains["os"] == "Amazon" %}
      - openssl-libs
      - krb5-libs
      - libicu
      {%- elif grains["os"] in ("Arch", "VMware Photon OS") %}
      - krb5
      - icu
      {%- endif %}
    {%- endif %}
{%- endif %}

{%- if grains['os'] == 'Windows' %}
create-start-runner-script:
  file.managed:
    - name: c:/start-runner.ps1
    - source: salt://github-actions-runner/files/start-runner.ps1
    - template: jinja
    - defaults:
      actions_runner_account: Administrator

add-runner-start-at-boot-task:
  cmd.script:
    - source: salt://github-actions-runner/files/add-start-at-boot-task.ps1
    - shell: powershell

{%- else %}

{{ runner_base_directory}}/actions-runner:
  file.directory:
    - user: actions-runner
    - group: actions-runner
    - recurse:
      - user
      - group
    - require:
      - install-runner-dependencies


/var/lib/cloud/scripts/per-boot/start-github-actions-runner.sh:
  file.managed:
    - source: salt://github-actions-runner/files/start-github-actions-runner.sh
    - mode: "0755"
    - template: jinja
    - defaults:
      actions_runner_account: actions-runner


/etc/systemd/system/github-actions-runner.service:
  file.managed:
    - source: salt://github-actions-runner/files/github-actions-runner.systemd.unit
    - mode: "0644"
    - template: jinja
    - defaults:
      actions_runner_account: actions-runner
{%- endif %}
