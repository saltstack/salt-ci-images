include:
  - python.gitpython

/etc/salt/master.conf.d/gitfs.conf:
  file.managed:
    - source: salt://halite/master/files/gitfs.conf
    - require:
      - cmd: gitpython


/etc/salt/master.conf.d/external_auth.conf:
  file.managed:
    - source: salt://halite/master/files/external_auth.conf

salt-master:
  service:
    - running
    - reload: True
    - require:
      - file: /etc/salt/master.conf.d/gitfs.conf
