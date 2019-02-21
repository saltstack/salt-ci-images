{%- if grains['os'] != 'Windows' %}
include:
  - python.pip
{%- endif %}

{%- if grains['os'] == 'MacOS' %}
  {% set install_type = 'pkg.installed' %}
{% else %}
  {% set install_type = 'pip2.installed' %}
{%- endif %}
supervisor:
  {{ install_type }}:
    - name: supervisor
    {% if grains['os'] != 'Windows' %}
    - require:
      - cmd: pip-install
    {%- endif %}
