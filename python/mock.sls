{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

mock:
  pip.installed:
    - name: mock
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
