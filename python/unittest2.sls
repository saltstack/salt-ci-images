{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

unittest2:
  pip.installed:
    - name: unittest2
  {% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
  {% endif %}
