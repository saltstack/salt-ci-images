include:
  - .config

setup glance db:
  file.directory:
    - name: /var/lib/glance
    - user: glance
    - group: glance
    - dir_mode: 0700

  cmd.run:
    - name: glance-manage db_sync
    - runas: glance 
    - unless: {{grains.get('setup_glance_db', 'false')}}

  grains.present:
    - name: setup_glance_db
    - value: true
    - require:
      - cmd: setup glance db
