include:
  - windows.repo
  {%- if salt['config.get']('py3', False) %}
  - python3
  {%- else %}
  - python27
  {%- endif %}
  - windows.nsis
  - windows.dlls
  - windows.envvars
  - windows.compiler

stop-minion:
  service.dead:
    - name: salt-minion
    - enable: False

windeps-sync-all:
  module.run:
    - name: saltutil.sync_all
    - require:
      - win-pkg-refresh
      - nsis
      - vcpp-compiler
    {%- if salt['config.get']('py3', False) %}
      - python3
    {%- else %}
      - python2
    {%- endif %}
    - order: 2
    - reload_modules: True
