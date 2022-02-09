/usr/bin/busybox:
  file.managed:
    - source: https://github.com/saltstack/salt-jenkins/files/8031454/busybox.zip
    - source_hash: sha256=d270442b2fff1c8ebbd076afaf2f6739abc5790526acfafd8fcdba3eab80ed73
    - mode: 0755
