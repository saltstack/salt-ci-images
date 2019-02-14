{%- if grains['os'] != 'Windows' %}
include:
  - python.pip
{%- endif %}

kubernetes:
  pip.installed:
    - name: kubernetes < 4.0
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    {%- if grains['os'] != 'Windows' %}
    - require:
      - cmd: pip-install
    {%- endif %}
