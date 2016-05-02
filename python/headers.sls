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

{% set py3 = pillar.get('py3', False) %}
{% if py3 and grains['os'] == 'CentOS' and grains['osrelease'].startswith('7') %}
  {% set python_dev = 'python34-devel' %}
{% endif %}

python-dev:
  pkg.installed:
    - name: {{ python_dev }}
    {% if grains['os'] == 'CentOS' and grains['osrelease'].startswith('5') %}
    - version: 0:2.6.8-3.el5
    {% endif %}
