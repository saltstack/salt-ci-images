{%- set win_bootstrap = True %}

include:
  - windows.repo
  {%- if salt['config.get']('py3', False) %}
  - python3
  {%- else %}
  - python27
  {%- endif %}
  - windows.git
  - windows.nsis
  - windows.compiler
  - windows.vcredist
  - windows.openssl
  - windows.pywin32
  - windows.wmi

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
