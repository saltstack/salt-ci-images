{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

{% set os_family = salt['grains.get']('os_family', '') %}
{% set os_major_release = salt['grains.get']('osmajorrelease', 0)|int %}

pyopenssl:
  pip.installed:
    - name: pyOpenSSL
    {%- if os_family == 'Debian' and os_major_release == 16 %}
    - upgrade: True
    {%- endif %}
