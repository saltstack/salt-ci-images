{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

urllib3:
  pip.installed:
    - name: urllib3
  {% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
  {% endif %}
