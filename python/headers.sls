{% if grains['os_family'] == 'RedHat' %}
  {% if grains['os'] in ('Fedora', 'Amazon') %}
    {% set python_dev = 'python-devel' %}
  {% elif grains['os'] == 'CentOS' %}
    {% if grains['osrelease'].startswith('5') %}
      {% set python_dev = 'python26-devel' %}
    {% else %}
      {% set python_dev = 'python-devel' %}
    {% endif %}
  {% else %}
    {% set python_dev = 'libpython-devel' %}
  {% endif %}
{% elif grains['os_family'] == 'Suse' %}
  {% set python_dev = 'python-devel' %}
{% else %}
  {% set python_dev = 'python-dev' %}
{% endif %}


python-dev:
  pkg.installed:
    - name: {{ python_dev }}
