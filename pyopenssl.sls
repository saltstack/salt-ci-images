{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
  - python.cffi
{% endif %}

pyopenssl:
  pip.installed:
    - name: pyOpenSSL
    - upgrade: True
    {%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
    {%- if pillar.get('py3', False) %}
    - require_in:
      - pip: cffi
    {%- endif %}
    {%- endif %}
