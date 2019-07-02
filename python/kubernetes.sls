
include:
  - python.requests
{%- if grains['os'] != 'Windows' %}
  - python.pip
{%- endif %}

kubernetes:
  pip.installed:
    - name: kubernetes < 4.0
    - require:
      - requests
    {%- if grains['os'] != 'Windows' %}
      - cmd: pip-install
    {%- endif %}
