{%- if grains['os'] != 'Windows' %}
include:
  - python.pip
{%- endif %}

argparse:
  pip.installed:
  {%- if grains['os'] != 'Windows' %}
    - require:
      - cmd: pip-install
  {%- endif %}
