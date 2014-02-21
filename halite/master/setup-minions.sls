{% from "halite/settings.jinja" import settings with context %}

setup-halite-minions:
  salt.state:
    - tgt: 'test-halite-minion-{{ settings.build_id }}-*'
    - sls:
      - halite.minions.install-apache
    - failhard: true
