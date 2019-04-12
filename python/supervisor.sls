{%- if grains['os'] != 'Windows' %}
include:
  - python.pip
{%- endif %}

supervisor:
  pip2.installed:
    - name: 'supervisor==3.3.5'
  {%- if grains['os'] != 'Windows' %}
    - require:
      - cmd: pip-install
  {%- endif %}
