{% if grains['os'] not in ('Windows',) %}
include:
  - python.pip
{% endif %}

urllib3:
  pip.installed:
    - name: urllib3
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    - require:
      - upgrade-installed-pip
