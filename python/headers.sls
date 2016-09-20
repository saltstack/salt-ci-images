{% if grains['os_family'] == 'RedHat' %}
  {% if grains['os'] in ('Fedora', 'Amazon') %}
    {% set python_dev = 'python-devel' %}
  {% elif grains['os'] == 'CentOS' or grains['os'] == 'RedHat' %}
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

{%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
python-dev:
  pkg.installed:
    - name: {{ python_dev }}
    {% if grains['os'] == 'CentOS' and grains['osrelease'].startswith('5') %}
    - fromrepo: saltstack
    {% endif %}
{%- endif %}
