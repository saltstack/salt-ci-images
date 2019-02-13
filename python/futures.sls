{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

futures:
  pip.installed:
    - name: futures
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
