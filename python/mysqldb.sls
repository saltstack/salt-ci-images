{%- if grains['os_family'] == 'Arch' %}
  {%- set mysqldb = 'mysql-python' %}
{%- elif grains['os_family'] == 'RedHat' %}
  {%- if grains['os'] == 'Fedora' %}
    {%- set mysqldb = 'python2-mysql' %}
  {%- else %}
    {%- set mysqldb = 'MySQL-python' %}
  {%- endif %}
{%- elif grains['os_family'] == 'Suse' %}
  {%- set mysqldb = 'python-MySQL-python' %}
  {%- if grains['osmajorrelease'] == '15' %}
      {%- set mysqldb = 'python2-PyMySQL' %}
      {%- if pillar.get('py3', False) %}
          {%- set mysqldb = 'python3-PyMySQL' %}
      {%- endif %}
  {% endif %}
{%- elif grains['os_family'] == 'FreeBSD' %}
  {%- set mysqldb = 'py27-MySQLdb' %}
{%- else %}
  {%- set mysqldb = 'python-mysqldb' %}
{%- endif %}

{%- if grains['os'] in ('Windows') %}
  {%- set install_method = 'pip.installed' %}
  {%- set mysqldb = 'pymysqldb' %}
{%- else %}
  {%- set install_method = 'pkg.installed' %}
{%- endif %}

mysqldb:
  {{ install_method }}:
    - name: {{ mysqldb }}
    {%- if install_method == 'pkg.installed' %}
    - aggregate: True
    {%- endif %}
