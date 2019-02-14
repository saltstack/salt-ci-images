{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

pytest-helpers-namespace:
  pip.installed:
    - name: pytest-helpers-namespace
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
