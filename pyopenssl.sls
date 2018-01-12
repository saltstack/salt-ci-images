{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

{%- if grains['os'] == 'CentOS' and grains['osmajorrelease'] == '6' %}
libffi-devel:
  pkg.installed
{%- endif %}

pyopenssl:
  pip.installed:
    - name: pyOpenSSL
    - upgrade: True
