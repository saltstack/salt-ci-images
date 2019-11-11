{%- set python2_apt = 'python-apt' %}
{%- set python3_apt = 'python3-apt' %}

python2-apt:
  pkg.installed:
    - name: {{ python2_apt }}
    - aggregate: True

python3-apt:
  pkg.installed:
    - name: {{ python3_apt }}
    - aggregate: True

python-apt:
  test.succeed_without_changes:
    - require:
      - python2-apt
      - python3-apt
