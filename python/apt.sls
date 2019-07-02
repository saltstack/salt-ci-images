{%- if pillar.get('py3', False) %}
  {%- set python_apt = 'python3-apt' %}
{%- else %}
  {%- set python_apt = 'python-apt' %}
{%- endif %}

python-apt:
  pkg.installed:
    - name: {{ python_apt }}
    - aggregate: True
