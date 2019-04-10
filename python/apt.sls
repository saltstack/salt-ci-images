{%- set os_family = salt['grains.get']('os_family', '') %}
{%- set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}

{%- if pillar.get('py3', False) %}
  {%- set python_apt = 'python3-apt' %}
{%- else %}
  {%- set python_apt = 'python-apt' %}
{%- endif %}

python-apt:
  pkg.installed:
    - name: {{ python_apt }}
    - aggregate: True
