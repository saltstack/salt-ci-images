{% if grains['os'] not in ('Windows',) %}
include:
  - gcc
  - python.pip
{% endif %}

pycrypto:
  pip.installed:
    - name: pycrypto >= 2.6.1
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
      - pkg: gcc
{% endif %}
