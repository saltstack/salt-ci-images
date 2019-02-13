{%- if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{%- endif %}

install_setproctitle:
  pip.installed:
    - name: setproctitle
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
{%- if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{%- endif %}
