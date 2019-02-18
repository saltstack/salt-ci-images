{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

setuptools-scm:
  pip.installed:
    - name: setuptools-scm
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
