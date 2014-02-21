salt-master:
  service:
    - running
    - restart: True
    - failhard: True
