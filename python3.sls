{%- set distro = salt['grains.get']('oscodename', '')  %}
{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}

{%- if os_family == 'RedHat' and os_major_release == 8 %}
  {%- set python3 = 'python36' %}
{%- elif os_family == 'Arch' %}
  {%- set on_arch = True %}
{%- else %}
  {%- set on_arch = False %}
{%- endif %}

{%- if os_family == 'Debian' %}
  {%- set on_debian = True %}
{%- else %}
  {%- set on_debian = False %}
{%- endif %}

{%- if os_family == 'MacOS' %}
  {%- set on_macos = True %}
{%- else %}
  {%- set on_macos = False %}
{%- endif %}

{%- if os_family == 'RedHat' and os_major_release == 2018 %}
  {%- set on_amazonlinux_1 = True %}
{%- else %}
  {%- set on_amazonlinux_1 = False %}
{%- endif %}

{%- if os_family == 'Ubuntu' and os_major_release >= 18 %}
  {%- set on_ubuntu_18_or_newer = True %}
{%- else %}
  {%- set on_ubuntu_18_or_newer = False %}
{%- endif %}

{%- if os_family == 'Windows' %}
  {%- set on_windows=True %}
{%- else %}
  {%- set on_windows=False %}
{%- endif %}

{%- if on_arch %}
  {%- set python3 = 'python' %}
{%- elif on_windows %}
  {%- set python3 = 'python3_x64' %}
{%- elif on_amazonlinux_1 %}
  {%- set python3 = 'python36' %}
{%- else %}
  {%- set python3 = 'python3' %}
{%- endif %}

{%- if on_macos %}
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

  {%- if on_windows %}
include:
  - windows.repo
  {%- elif on_debian %}
include:
  - python.apt
    {%- if pillar.get('py3', False) and on_ubuntu_18_or_newer %}
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

{%- endif %}
