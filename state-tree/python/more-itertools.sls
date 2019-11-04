include:
  - python.pip
{%- if pillar.get('py3', False) %}
{%- set itertools = 'more-itertools==6.0.0' %}
{%- else %}
{#- more-itertools 5.0.0 is the last version which supports Python 2.7 or 2x at all #}
{%- set itertools = 'more-itertools==5.0.0' %}
{%- endif %}

more-itertools:
  pip.installed:
    - name: '{{ itertools }}'
    - require:
      - cmd: pip-install
