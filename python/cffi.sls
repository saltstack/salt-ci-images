{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

cffi:
  pip.installed:
    - name: cffi
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
