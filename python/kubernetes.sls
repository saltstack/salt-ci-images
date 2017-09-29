{%- if grains['os'] != 'Windows' %}
include:
  - python.pip
{%- endif %}

kubernetes:
  pip.installed:
    - name: kubernetes
    {%- if salt['config.get']('virtualenv_path', None) %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    {%- if grains['os'] != 'Windows' %}
    - require:
      - cmd: pip-install
    {%- endif %}
