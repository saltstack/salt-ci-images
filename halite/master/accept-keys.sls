{% from "halite/settings.jinja" import settings with context %}

accept-minion-keys:
  salt.function:
    - name: 'cmd.run_all'
    - tgt: {{ settings.master_id }}
    - arg:
      - 'salt-key -ya test-halite-minion-{{ settings.build_id }}-*'
    - failhard: True
