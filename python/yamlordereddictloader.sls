{%- if grains['os'] != 'Windows' %}
include:
  - python.pip
{%- endif %}

yamlordereddictloader:
  pip.installed:
    - name: yamlordereddictloader
    {%- if grains['os'] != 'Windows' %}
    - require:
      - cmd: pip-install
    {%- endif %}
