include:
  - .config

setup keystone db:
  file.directory:
    - name: /var/lib/keystone
    - user: keystone
    - group: keystone
    - dir_mode: 0700

  cmd.run:
    - name: keystone-manage db_sync
    - runas: keystone
    - unless: {{grains.get('setup_keystone_db', 'false')}}

  grains.present:
    - name: setup_keystone_db
    - value: true
    - require:
      - cmd: setup keystone db

setup keystone fernet:
  file.directory:
    - name: /etc/keystone/fernet-keys/
    - user: keystone
    - group: keystone
    - dir_mode: 0700

  cmd.run:
    - name: keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
    - runas: keystone
    - unless: {{grains.get('setup_keystone_fernet', 'false')}}

  grains.present:
    - name: setup_keystone_fernet
    - value: true
    - require:
      - cmd: setup keystone fernet
