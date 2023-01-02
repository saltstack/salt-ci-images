{%- if grains['os'] == 'VMware Photon OS' %}
{#- Photon OS has /opt with perms too closed for another user to access #}
/opt:
  file.directory:
    - user: root
    - group: sudo
    - dir_mode: "0751"
{%- endif %}

/opt/hostedtoolcache:
  file.directory:
    - user: actions-runner
    - group: actions-runner
    - dir_mode: "0755"

download-and-decompress-runner-tarball:
  archive.extracted:
    - name: /opt/actions-runner
    - source: {{ pillar["github_actions_runner_tarball_url"] }}
    - user: actions-runner
    - group: actions-runner
    - skip_verify: true
    - keep_source: false

/opt/actions-runner/.env:
  file.append:
    - text:
      - ImageOS={{ grains.get('osfinger', grains['osfullname'].replace(' ', '-')) }}
    - require:
      - download-and-decompress-runner-tarball

install-runner-dependencies:
  {%- if pillar["github_actions_runner_install_dependencies"] %}
  cmd.run:
    - name: /opt/actions-runner/bin/installdependencies.sh
    - require:
      - download-and-decompress-runner-tarball
  {%- else %}
  pkg.installed:
    - pkgs:
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

/opt/actions-runner:
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
