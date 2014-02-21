include:
  - python.gitpython

/etc/salt/master.d/halite.conf:
  file.managed:
    - source: salt://halite/master/files/halite-master-config.conf
    - require:
      - cmd: gitpython

/etc/salt/master.d/gitfs.conf:
  file.managed:
    - source: salt://halite/master/files/gitfs.conf
    - require:
      - file: /etc/salt/master.d/halite.conf


/etc/salt/master.d/external_auth.conf:
  file.managed:
    - source: salt://halite/master/files/external_auth.conf
