include:
  {%- if grains['os'] not in ('Windows',) %}
  - gcc
  {%- endif %}
  - python.pip

pycrypto:
  pip.installed:
    - name: pycrypto >= 2.6.1
    - require:
      - cmd: pip-install
    {%- if grains['os'] != 'Windows' %}
      - pkg: gcc
    {%- endif %}
