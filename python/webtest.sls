{% if grains['os'] != 'Windows' %}
include:
  - python.pip
{% endif %}

webtest:
  pip.installed:
    - name: webtest
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
