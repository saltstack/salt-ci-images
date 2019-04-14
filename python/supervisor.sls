{%- if grains['os'] != 'Windows' %}
include:
  - python.pip
{%- endif %}

supervisor:
  {%- if grains['os'] == 'MacOS' %}
  pkg.installed:
    - name: supervisor
  {%- else %}
  pip2.installed:
    - name: 'supervisor==3.3.5'
    {%- if grains['os'] != 'Windows' %}
    - require:
      - cmd: pip-install
    {%- endif %}
  {%- endif %}
