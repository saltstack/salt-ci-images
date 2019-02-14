{% if grains['os'] not in ('Windows',) %}
include:
  - gcc
  - python.pip
{% endif %}

pycryptodomex:
  pip.installed:
    - name: pycryptodomex
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
      - pkg: gcc
{% endif %}
