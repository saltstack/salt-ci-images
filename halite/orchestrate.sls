{% from "halite/settings.jinja" import settings with context %}

deploy-master:
  salt.state:
    - tgt: {{ grains.get('id') }}
    - sls:
      - halite.master.deploy
    - failhard: true


deploy-minions:
  salt.state:
    - tgt: {{ grains.get('id') }}
    - sls:
      - halite.minions.deploy
    - failhard: true

accept-minion-keys:
  salt.function:
    - name: 'cmd.run_all'
    - tgt: {{ settings.master_id }}
    - arg:
      - 'salt-key -ya test-halite-minion-{{ settings.build_id }}-*'

configure-master:
  salt.state:
    - tgt: {{ settings.master_id }}
    - sls:
      - halite.master.config
      - halite.master.setup-halite
      - halite.master.restart-service
    - failhard: true


setup-minions:
  salt.state:
    - tgt: {{ settings.master_id }}
    - sls:
      - halite.master.setup-minions
    - failhard: true


run-halite-testsuite:
  salt.state:
    - tgt: {{ settings.master_id }}
    - sls:
      - halite.master.run-halite-testsuite
    - failhard: true
