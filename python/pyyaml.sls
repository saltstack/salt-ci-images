include:
  - gcc
  - python.pip

PyYAML:
  pip.installed:
    - name: PyYAML >= 3.12
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require:
      - cmd: pip-install
      - pkg: gcc
