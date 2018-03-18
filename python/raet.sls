include:
  {%- if grains['os'] != 'Windows' %}
  - python.pip
  {%- endif %}
  - python.six

raet:
  pip.installed:
    - bin_env: {{ salt['config.get']('virtualenv_path', '') }}
    - cwd: {{ salt['config.get']('pip_cwd', '') }}
    - require:
    {%- if grains['os'] != 'Windows' %}
      - cmd: pip-install
    {%- endif %}
      - pip: six

