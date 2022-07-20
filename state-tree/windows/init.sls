include:
  - windows.git
  - windows.7zip
  - windows.ca_roots
  - windows.compiler
  - windows.vcredist
  - windows.openssl
  - windows.powershell_core

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
