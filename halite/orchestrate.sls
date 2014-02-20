deploy-master:
  salt.state:
    - tgt: {{ grains.get('id') }}
    - sls:
      - halite.master.deploy
    - failhard: true


configure-master:
  salt.state:
    - tgt: 'test-halite-master-*'
    - sls:
      - halite.master.config
      - halite.master.setup-halite
    - require:
      - salt: deploy-master
    - failhard: true


deploy-minions:
  salt.state:
    - tgt: {{ grains.get('id') }}
    - sls:
      - halite.minions.deploy
    - require:
      - salt: configure-master
    - failhard: true


accept-minion-keys:
  salt.state:
    - tgt: 'test-halite-master-*'
    - sls:
      - halite.master.accept-keys
    - require:
      - salt: deploy-minions
    - failhard: true


configure-minions:
  salt.state:
    - tgt: 'test-halite-minion-*'
    - sls:
      - halite.minions.install-halite
    - require:
      - salt: accept-minion-keys
    - failhard: true


run-halite-testsuite:
  salt.state:
    - tgt: 'test-halite-master-*'
    - sls:
      - halite.master.run-halite-testsuite
    - require:
      - salt: configure-minions
    - failhard: true
