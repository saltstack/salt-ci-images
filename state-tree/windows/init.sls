{%- set win_bootstrap = True %}

include:
  - windows.git
  - windows.nsis
  - windows.ca_roots
  - windows.compiler
  - windows.vcredist
  - windows.openssl

stop-minion:
  service.dead:
    - name: salt-minion
    - enable: False

windeps-sync-all:
  module.run:
    - name: saltutil.sync_all
    - require:
      - nsis
      - vcpp-compiler
    - order: 2
    - reload_modules: True
