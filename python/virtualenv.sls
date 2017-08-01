{%- set virtualenv_pin = '' if grains['os'] == 'MacOS' else '==1.10' %}

{% if grains['os'] not in ('Windows') %}
include:
  - python.pip
{% endif %}

virtualenv:
  pip.installed:
    - name: virtualenv{{ virtualenv_pin }}
{% if grains['os'] not in ('Windows') %}
    - require:
      - cmd: pip-install
{% endif %}
