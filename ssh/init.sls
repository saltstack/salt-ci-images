/etc/ssh/sshd_config:
  file.managed:
    - source: salt://ssh/files/sshd_config
    - failhard: True
