{%- if grains['os'] != 'Windows' %}
include:
  - python.pip
{%- endif %}

supervisor:
  pip2.installed:
    - name: supervisor
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
  {%- if grains['os'] != 'Windows' %}
    - require:
      - cmd: pip-install
  {%- endif %}
