{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}

{%- if os_family == 'RedHat' and os_major_release == 2018 %}
  {%- set on_amazonlinux_1 = True %}
{%- else %}
  {%- set on_amazonlinux_1 = False %}
{%- endif %}

include:
  - python.pip

nox:
  pip.installed:
    - name: 'nox-py2'
    {%- if grains['os'] == 'Windows' %}
    - unless:
      - 'WHERE nox.exe'
    {%- else %}
    - onlyif:
      - '[ "$(which nox 2>/dev/null)" = "" ]'
    {%- endif %}
    {%- if on_amazonlinux_1 %}
    - install_options:
      - --prefix=/usr
    {%- endif %}
    - require:
      - pip-install
