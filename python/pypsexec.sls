{% if grains['os'] in ('CentOS',) %}
include:
  - python.pip

pypsexec:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    - require:
      - cmd: pip-install
{% endif %}
