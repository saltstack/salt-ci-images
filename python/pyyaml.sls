include:
  - gcc
  - python.pip

PyYAML:
  pip.installed:
    {%- if salt['config.get']('virtualenv_path', None) is not None %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require:
      - cmd: python-pip
      - pkg: gcc
