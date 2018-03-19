{% if grains['os'] not in ('Windows',) %}
include:
  - gcc
  - python.pip
{% endif %}

pycrypto:
  pip.installed:
    - name: pycrypto >= 2.6.1
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
      - pkg: gcc
{% endif %}
