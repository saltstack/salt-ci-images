deploy-master:
  salt.state:
    - tgt: {{ grains.get('id') }}
    - sls:
      - halite.master.deploy


configure-master:
  salt.state:
    - tgt: 'test-halite-master-*'
    - sls:
      - halite.master.config
      - apache
      - halite.master.setup-halite
    - require:
      - salt: deploy-master
