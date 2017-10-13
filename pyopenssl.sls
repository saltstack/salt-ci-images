{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

pyopenssl:
  pip.installed:
    - name: pyOpenSSL
    - upgrade: True
