{%- set python_apt = 'python3-apt' %}

python-apt:
  pkg.installed:
    - name: {{ python_apt }}
    - aggregate: False
