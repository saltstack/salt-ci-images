include:
  - python.requests
  - python.docker
{%- if grains['os'] not in ('Windows',) %}
  - python.pip
{%- endif %}

{%- set moto_version = 'moto==1.1.25' %}

moto:
  pip.installed:
    - name: moto==1.3.7
    - require:
      - requests
      - docker_py
{%- if grains['os'] != 'Windows' %}
      - cmd: pip-install
{%- endif %}
