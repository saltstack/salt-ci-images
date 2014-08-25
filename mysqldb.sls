{% if grains['os_family'] == 'Arch' %}
  {% set mysqldb = 'mysql-python' %}
{% elif grains['os_family'] == 'RedHat' %}
  {% set mysqldb = 'MySQL-python' %}
{% elif grains['os_family'] == 'Suse' %}
  {% set mysqldb = 'python-mysql' %}
{% else %}
  {% set mysqldb = 'python-mysqldb' %}
{% endif %}

mysqldb:
  pkg.installed:
    - name: {{ mysqldb }}