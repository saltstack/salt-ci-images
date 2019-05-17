{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

watchdog:
  pip.installed:
    - name: watchdog
    {% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
    {% endif %}
