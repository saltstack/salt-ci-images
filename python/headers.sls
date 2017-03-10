{% if grains['os_family'] == 'RedHat' %}
  {% if grains['os'] in ('Fedora', 'Amazon') %}
    {%- if pillar.get('py3', False) %}
      {% set python_dev = 'python34-devel' %}
    {%- else %}
      {% set python_dev = 'python-devel' %}
    {%- endif %}
  {% elif grains['os'] == 'CentOS' or grains['os'] == 'RedHat' %}
    {% if grains['osrelease'].startswith('5') %}
      {% set python_dev = 'python26-devel' %}
    {% else %}
      {%- if pillar.get('py3', False) %}
        {% set python_dev = 'python34-devel' %}
      {%- else %}
        {% set python_dev = 'python-devel' %}
      {%- endif %}
    {% endif %}
  {% else %}
    {%- if pillar.get('py3', False) %}
      {% set python_dev = 'libpython34-devel' %}
    {%- else %}
      {% set python_dev = 'libpython-devel' %}
    {%- endif %}
  {% endif %}
{% elif grains['os_family'] == 'Suse' %}
  {%- if pillar.get('py3', False) %}
    {% set python_dev = 'python34-devel' %}
  {%- else %}
    {% set python_dev = 'python-devel' %}
  {%- endif %}
{% else %}
  {%- if pillar.get('py3', False) %}
    {% set python_dev = 'python34-dev' %}
  {%- else %}
    {% set python_dev = 'python-dev' %}
  {%- endif %}
{% endif %}

{%- if grains['os_family'] not in ('Arch', 'Solaris', 'FreeBSD', 'Gentoo', 'MacOS') %}
python-dev:
  pkg.installed:
    - name: {{ python_dev }}
    {% if grains['os'] == 'CentOS' and grains['osrelease'].startswith('5') %}
    - fromrepo: saltstack
    {% endif %}
{%- endif %}
