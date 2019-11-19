{%-  set on_windows = salt['grains.get']('os_family') == 'Windows' %}
include:
  {%- if on_windows %}
  - windows.compiler
  {%- else %}
  - gcc
  {%- endif %}
  - python.pip

PyYAML:
  pip.installed:
    - name: 'PyYAML >= 3.12, < 5.1'
    - ignore_installed: true
    - require:
      - cmd: pip-install
    {%- if on_windows %}
      - pkg: vcpp-compiler
    {%- else %}
      - pkg: gcc
    {%- endif %}
