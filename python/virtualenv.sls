{%- set virtualenv_pin = '' %}

{%- if grains['os'] != 'Windows' %}
include:
  - python.pip
{%- endif %}

virtualenv:
  pip.installed:
    - name: virtualenv{{ virtualenv_pin }}
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
