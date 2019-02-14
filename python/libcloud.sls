{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

apache-libcloud:
  pip.installed:
    - name: 'apache-libcloud==2.0.0'
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
