{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

pylxd:
  pip.installed:
    - name: 'pylxd>=2.2.5'
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
{% if grains['os'] not in ('Windows',) %}
    - require:
      - cmd: pip-install
{% endif %}
