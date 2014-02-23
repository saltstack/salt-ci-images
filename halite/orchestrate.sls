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
    - failhard: True


configure-master:
  salt.state:
    - tgt: {{ settings.master_id }}
    - sls:
      - halite.master.config
      - halite.master.setup-halite
    - failhard: true


restart-master:
  salt.function:
    - name: 'cmd.run_all'
    - tgt: {{ settings.master_id }}
    - arg:
      - 'salt-call service.restart salt-master'
    - failhard: True


install-minions-apache:
  salt.function:
    - name: 'cmd.run_all'
    - tgt: {{ settings.master_id }}
    - arg:
      - 'salt test-halite-minion-{{ settings.build_id }}-* state.sls apache'
    - failhard: True


run-halite-testsuite:
  salt.state:
    - tgt: {{ settings.master_id }}
    - sls:
      - halite.master.run-halite-testsuite
    - failhard: true
