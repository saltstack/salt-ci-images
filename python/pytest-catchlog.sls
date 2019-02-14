{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

pytest-catchlog:
  pip.installed:
    - name: pytest-catchlog
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
