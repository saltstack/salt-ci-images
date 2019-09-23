
include:
  - python.requests
{%- if grains['os'] != 'Windows' %}
  - python.pip
{%- endif %}

kubernetes:
  pip.installed:
    - name: kubernetes < 4.0
    - ignore_installed: true
    - require:
      - requests
    {%- if grains['os'] != 'Windows' %}
      - cmd: pip-install
    {%- endif %}
