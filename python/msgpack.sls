{% if grains['os'] not in ('Windows',) %}
include:
  - gcc
  - python.pip
{% endif %}

msgpack-python:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    - name: 'msgpack-python >= 0.4.2, != 0.5.5'
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
      - pkg: gcc
{% endif %}
