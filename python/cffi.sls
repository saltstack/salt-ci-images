{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

cffi:
  pip.installed:
    - name: cffi==1.11.0
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
