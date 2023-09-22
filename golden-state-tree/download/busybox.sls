/usr/bin/busybox:
  file.managed:
  {%- if grains['osarch'] == 'aarch64' %}
    - source: https://github.com/saltstack/salt-jenkins/files/12686271/busybox.arch64.zip
    - source_hash: f6c93120cec5f4a6414ae7e7725ef20dd51f07b93f5f69961c1ce2c3ab13b446
  {%- else %}
    - source: https://github.com/saltstack/salt-jenkins/files/8031454/busybox.zip
    - source_hash: sha256=d270442b2fff1c8ebbd076afaf2f6739abc5790526acfafd8fcdba3eab80ed73
  {%- endif %}
    - mode: 0755


run-busybox:
  cmd.run:
    - name: /usr/bin/busybox pwd && exit 0 || exit 1
    - require:
      - /usr/bin/busybox
