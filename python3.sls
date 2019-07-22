{%- set distro = salt['grains.get']('oscodename', '')  %}
{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}
{%- set symlink_set = False %}

{%- if os_family == 'RedHat' and os_major_release == 7 %}
  {%- set python3_path = '/bin/python3.4' %}
  {%- set symlink_set = True %}
  {%- set python3 = 'python34' %}
{%- elif os_family == 'Arch' %}
  {%- set python3 = 'python' %}
{%- elif grains['os'] == 'Windows' %}
  {%- set python3 = 'python3_x64' %}
{%- else %}
  {%- set python3 = 'python3' %}
{%- endif %}

{%- if os_family == 'MacOS' %}
python3:
  file.managed:
    - source: https://www.python.org/ftp/python/3.6.4/python-3.6.4-macosx10.6.pkg
    - name: /tmp/python-3.6.4-macosx10.6.pkg
    - user: root
    - group: wheel
    - skip_verify: True
  macpackage.installed:
    - name: /tmp/python-3.6.4-macosx10.6.pkg
    - reload_modules: True
install_certs:
  cmd.run:
    - name: /Applications/Python\ 3.6/Install\ Certificates.command
{%- else %}

  {%- if grains['os'] == 'Windows' %}
include:
  - windows.repo
  {%- elif os_family == 'Debian' %}
include:
  - python.apt
    {%- if pillar.get('py3', False) and grains['os'] == 'Ubuntu' and os_major_release >= 18 %}
  - python.distutils
    {%- endif %}
  {%- endif %}

python3:
  pkg.installed:
    - name: {{ python3 }}
    {%- if grains['os'] != 'Windows' %}
    - aggregate: True
    {%- else %}
    - aggregate: False
    - version: '3.5.4150.0'
    - extra_install_flags: "TargetDir=C:\\Python35 Include_doc=0 Include_tcltk=0 Include_test=0 Include_launcher=1 PrependPath=1 Shortcuts=0"
    - require:
      - win-pkg-refresh
    {%- endif %}

  {%- if symlink_set %}
set_python3_symlink:
  file.symlink:
    - name: /bin/python3
    - target: {{ python3_path }}
  {%- endif %}
{%- endif %}
