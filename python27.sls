{%- if grains['os'] == 'Windows' %}
  {% if grains['cpuarch'].lower() == 'x86' %}
    {%- set python2 = 'python2_x86' %}
  {%- else %}
    {%- set python2 = 'python2_x64' %}
  {%- endif %}
{%- elif grains['os'] == 'openSUSE' %}
  {%- set python2 = 'python' %}
{%- elif grains['os'] == 'CentOS' or grains['os'] == 'RedHat' %}
  {%- if grains['osrelease'].startswith('6') %}
    {%- set python2 = 'python27' %}
  {%- else %}
    {%- set python2 = 'python' %}
  {%- endif %}
{%- elif grains['os'] in ('Ubuntu', 'Debian') %}
  {%- set python2 = 'python2.7' %}
{%- elif grains['os'] == 'Fedora' %}
  {%- set python2 = 'python2' %}
{%- elif grains['os_family'] == 'Arch' %}
  {%- set python2 = 'python2' %}
{%- else %}
  {%- set python2 = 'python' %}
{%- endif %}

{%- if grains['os'] == 'Windows' %}
include:
  - windows.repo
{%- endif %}

python2:
  pkg.latest:
    - name: {{ python2 }}
    {%- if grains['os'] != 'Windows' %}
    - aggregate: True
    {%- else %}
    - aggregate: False
    - version: '2.7.1150'
    - extra_install_flags: "ADDLOCAL=DefaultFeature,SharedCRT,Extensions,pip_feature,PrependPath TargetDir=C:\\Python27"
    - require:
      - win-pkg-refresh
    {%- endif %}
