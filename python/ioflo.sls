{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

install_ioflo:
  pip.installed:
    - name: ioflo
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
