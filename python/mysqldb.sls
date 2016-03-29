{% if grains['os_family'] == 'Arch' %}
  {% set mysqldb = 'mysql-python' %}
{% elif grains['os_family'] == 'RedHat' %}
  {% set mysqldb = 'MySQL-python' %}
{% elif grains['os_family'] == 'Suse' %}
  {% set mysqldb = 'python-mysql' %}
{% elif grains['os_family'] == 'FreeBSD' %}
  {% set mysqldb = 'py27-MySQLdb' %}
{% elif grains['osfinger'] == 'Fedora-23' %}
  {% set mysqldb = 'python2-mysql' %}
{% else %}
  {% set mysqldb = 'python-mysqldb' %}
{% endif %}

mysqldb:
  pkg.installed:
    - name: {{ mysqldb }}
