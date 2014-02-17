include:
  - python.gitpython

/etc/salt/master.conf.d/gitfs.conf:
  file.managed:
    - source: salt://halite/master/files/gitfs.conf
    - require:
      - cmd: gitpython

salt-master:
  service:
    - running
    - reload: True
    - require:
      - file: /etc/salt/master.conf.d/gitfs.conf
