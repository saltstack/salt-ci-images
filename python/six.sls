{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

six:
  pip.installed:
    - upgrade: true
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
