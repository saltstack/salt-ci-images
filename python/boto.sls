include:
  - python.pip

boto:
  pip.installed:
    {%- if salt['config.get']('virtualenv_path', None)  %}
    - bin_env: {{ salt['config.get']('virtualenv_path') }}
    {%- endif %}
    - require:
      - cmd: python-pip