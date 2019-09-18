{%- set nox_version = '2019.6.25' %}
{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}

{%- if os_family == 'RedHat' and (os_major_release == 2018 or os_major_release == 8) %}
  {%- set use_usr_prefix = True %}
{%- else %}
  {%- set use_usr_prefix = False %}
{%- endif %}

include:
  - python.pip

{%- set which_nox = 'nox' | which %}

{%- if not which_nox %}
nox:
  pip.installed:
    - name: 'nox-py2=={{ nox_version }}'
    {%- if grains['os'] == 'Windows' %}
    - unless:
      - 'WHERE nox.exe'
    {%- else %}
    - onlyif:
      - '[ "$(which nox 2>/dev/null)" = "" ]'
    {%- endif %}
    {%- if use_usr_prefix %}
    - install_options:
      - --prefix=/usr
    {%- endif %}
    - require:
      - pip-install
{%- endif %}
