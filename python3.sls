{%- set distro = salt['grains.get']('oscodename', '')  %}
{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}

{%- if os_family == 'RedHat' and os_major_release == 7 %}
  {%- set python3 = 'python34' %}
{%- elif os_family == 'Arch' %}
  {%- set python3 = 'python' %}
{%- elif grains['os'] == 'Windows' %}
  {%- set python3 = 'python3_x64' %}
{%- else %}
  {%- set python3 = 'python3' %}
{%- endif %}

{%- if grains['os'] == 'Windows' %}
include:
  - windows.repo
{%- endif %}

python3:
  pkg.installed:
    - name: {{ python3 }}
    {%- if grains['os'] != 'Windows' %}
    - aggregate: True
    {%- else %}
    - aggregate: False
    - version: '3.5.2150.0'
    - extra_install_flags: "TargetDir=C:\\Python35 Include_doc=0 Include_tcltk=0 Include_test=0 Include_launcher=1 PrependPath=1 Shortcuts=0"
    - require:
      - win-pkg-refresh
    {%- endif %}
