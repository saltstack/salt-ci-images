{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

futures:
  pip.installed:
    - name: futures
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
