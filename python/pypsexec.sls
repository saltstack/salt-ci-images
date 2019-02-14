{% if grains['os'] in ('CentOS',) %}
include:
  - python.pip

pypsexec:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - require:
      - cmd: pip-install
{% endif %}
