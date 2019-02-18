{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

pylxd:
  pip.installed:
    - name: 'pylxd>=2.2.5'
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
