include:
  - .config

setup nova db directory:
  file.directory:
    - name: /var/lib/nova
    - user: nova
    - group: nova
    - dir_mode: 0700

setup nova api db:
  cmd.run:
    - name: nova-manage api_db sync
    - runas: nova
    - unless: {{grains.get('setup_nova_api_db', 'false')}}

  grains.present:
    - name: setup_nova_api_db
    - value: true
    - require:
      - cmd: setup nova api db

setup nova db:
  cmd.run:
    - name: nova-manage db sync
    - runas: nova
    - unless: {{grains.get('setup_nova_db', 'false')}}

  grains.present:
    - name: setup_nova_db
    - value: true
    - require:
      - cmd: setup nova db
