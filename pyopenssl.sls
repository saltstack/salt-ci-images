{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
  - python.cffi
{% endif %}

{%- if grains['os'] == 'CentOS' and grains['osmajorrelease']|int == 6 %}
libffi-devel:
  pkg.installed
{%- endif %}

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
