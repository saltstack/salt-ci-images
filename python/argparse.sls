{%- if grains['os'] != 'Windows' %}
include:
  - python.pip
{%- endif %}

argparse:
  pip.installed:
    {%- if salt['config.get']('virtualenv_path', None) %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    {%- if grains['os'] != 'Windows' %}
    - require:
      - cmd: pip-install
    {%- endif %}
