{%- set distro = salt['grains.get']('oscodename', '')  %}
{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}
{%- set os = salt['grains.get']('os', '') %}

{%- if os_family == 'RedHat' %}
  {%- if os_major_release == 2018 %}
    {%- set pip_pkg_name = 'python36-pip' %}
  {%- else %}
    {%- set pip_pkg_name = 'python3-pip' %}
  {%- endif %}
{%- elif os_family in ('Debian', 'Ubuntu') %}
  {%- set pip_pkg_name = 'python3-pip' %}
{%- elif os_family == 'Arch' %}
  {%- set pip_pkg_name = 'python-pip' %}
{%- elif os_family == 'FreeBSD' %}
  {%- set pip_pkg_name = 'py39-pip' %}
{%- else %}
  {%- set pip_pkg_name = 'python3-pip' %}
{%- endif %}

python3-pip:
  pkg.installed:
    - name: {{ pip_pkg_name }}
