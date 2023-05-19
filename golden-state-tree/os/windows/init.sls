include:
  - .pkgs
  - .download

  {%- if pillar.get('github_actions_runner', False) %}
  - github-actions-runner
  {%- endif %}

stop-minion:
  service.dead:
    - name: salt-minion
    - enable: False

windeps-sync-all:
  module.run:
    - name: saltutil.sync_all
    - require:
      - vcpp-compiler
    - order: 2
    - reload_modules: True
