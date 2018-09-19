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
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    {%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
    {%- endif %}
